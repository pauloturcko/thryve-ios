import AVFoundation
import Foundation
import Observation
import Speech

enum VoiceRecorderError: LocalizedError {
    case microphoneDenied
    case unsupported
    case unavailable

    var errorDescription: String? {
        switch self {
        case .microphoneDenied: "Libere o microfone em Ajustes › Thryve para falar o gasto."
        case .unsupported: "Este iPhone não reconhece fala em português. Digite o gasto."
        case .unavailable: "Não foi possível usar o microfone agora. Tente de novo."
        }
    }
}

/// Quanto da voz está no grave, no médio e no agudo, de 0 a 1. A bolinha deforma a borda com isso.
struct VoiceSpectrum: Equatable, Sendable {
    var low = 0.0
    var mid = 0.0
    var high = 0.0

    static let silent = VoiceSpectrum()
}

/// Uma leitura do microfone, a cada bloco de áudio (~85 ms): o volume de cada pedaço
/// de 20 ms, na ordem, e as faixas da voz no bloco todo.
private struct VoiceReading: Sendable {
    let levels: [Double]
    let spacing: Double
    let spectrum: VoiceSpectrum
}

/// Grava do microfone e transcreve no próprio aparelho com o `SpeechAnalyzer`, em pt-BR.
@MainActor
@Observable
final class VoiceRecorder {
    enum State: Equatable {
        case idle
        case preparing
        case listening
        case finishing
    }

    private(set) var state: State = .idle
    private(set) var transcript = ""
    /// Volume da voz de 0 a 1 em pedaços de 20 ms, do último bloco de áudio, para a bolinha
    /// acompanhar as sílabas. `levelSequence` muda a cada bloco novo.
    private(set) var levels: [Double] = []
    private(set) var levelSpacing = 0.02
    private(set) var levelSequence = 0
    private(set) var spectrum = VoiceSpectrum.silent

    /// Depois de ouvir alguma coisa, esse tempo calado encerra a gravação.
    private static let silenceTimeout: TimeInterval = 1.8
    /// Sem ouvir nada, desiste depois desse tempo.
    private static let noSpeechTimeout: TimeInterval = 8
    private static let voiceThreshold = 0.22
    private static let locale = Locale(identifier: "pt-BR")

    private var finalizedText = ""
    private var volatileText = ""
    private var engine: AVAudioEngine?
    private var analyzer: SpeechAnalyzer?
    private var input: AsyncStream<AnalyzerInput>.Continuation?
    private var resultsTask: Task<Void, Never>?
    private var levelsTask: Task<Void, Never>?
    private var readings: AsyncStream<VoiceReading>.Continuation?
    private var silenceTask: Task<Void, Never>?
    private var startedAt = Date.now
    private var lastVoiceAt: Date?

    /// Chamado quando a gravação para sozinha pelo silêncio.
    var onAutoStop: (() -> Void)?

    func start() async throws {
        guard state == .idle else { return }

        guard await AVAudioApplication.requestRecordPermission() else { throw VoiceRecorderError.microphoneDenied }
        guard SpeechTranscriber.isAvailable,
              let locale = await SpeechTranscriber.supportedLocale(equivalentTo: Self.locale)
        else { throw VoiceRecorderError.unsupported }

        state = .preparing
        finalizedText = ""
        volatileText = ""
        transcript = ""
        levels = []
        spectrum = .silent

        do {
            let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
            // Na primeira vez o iOS baixa o modelo de português.
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try await request.downloadAndInstall()
            }
            guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
                throw VoiceRecorderError.unsupported
            }

            let (stream, continuation) = AsyncStream.makeStream(of: AnalyzerInput.self)
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            try await analyzer.start(inputSequence: stream)

            resultsTask = Task { [weak self] in
                do {
                    for try await result in transcriber.results {
                        self?.handle(text: String(result.text.characters), isFinal: result.isFinal)
                    }
                } catch {}
            }

            let (readingStream, readingContinuation) = AsyncStream.makeStream(of: VoiceReading.self, bufferingPolicy: .bufferingNewest(1))
            levelsTask = Task { [weak self] in
                for await reading in readingStream {
                    self?.update(with: reading)
                }
            }

            try Self.activateSession()
            let engine = AVAudioEngine()
            try Self.startCapture(
                on: engine,
                feed: AnalyzerFeed(format: format, input: continuation, readings: readingContinuation)
            )

            readings = readingContinuation
            self.engine = engine
            self.analyzer = analyzer
            input = continuation
            startedAt = .now
            lastVoiceAt = nil
            state = .listening
            watchSilence()
        } catch {
            await cancel()
            throw error as? VoiceRecorderError ?? .unavailable
        }
    }

    /// Para de ouvir e devolve a frase final.
    func stop() async -> String {
        guard state == .listening else { return transcript }
        state = .finishing
        silenceTask?.cancel()
        stopCapture()

        try? await analyzer?.finalizeAndFinishThroughEndOfInput()
        await resultsTask?.value
        reset()
        return transcript
    }

    func cancel() async {
        silenceTask?.cancel()
        stopCapture()
        await analyzer?.cancelAndFinishNow()
        resultsTask?.cancel()
        reset()
        transcript = ""
    }

    private func handle(text: String, isFinal: Bool) {
        if isFinal {
            finalizedText += text
            volatileText = ""
        } else {
            volatileText = text
        }
        transcript = (finalizedText + volatileText).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func update(with reading: VoiceReading) {
        guard state == .listening else { return }
        levels = reading.levels
        levelSpacing = reading.spacing
        levelSequence += 1
        spectrum = reading.spectrum
        if reading.levels.contains(where: { $0 > Self.voiceThreshold }) {
            lastVoiceAt = .now
        }
    }

    private func watchSilence() {
        silenceTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                guard let self, self.state == .listening else { return }

                let now = Date.now
                let silentAfterSpeech = self.lastVoiceAt.map { now.timeIntervalSince($0) > Self.silenceTimeout } ?? false
                let neverSpoke = self.lastVoiceAt == nil && now.timeIntervalSince(self.startedAt) > Self.noSpeechTimeout
                if (silentAfterSpeech && !self.transcript.isEmpty) || neverSpoke {
                    self.onAutoStop?()
                    return
                }
            }
        }
    }

    private func stopCapture() {
        engine?.inputNode.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        input?.finish()
        input = nil
        readings?.finish()
        readings = nil
        levelsTask?.cancel()
        levelsTask = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func reset() {
        analyzer = nil
        resultsTask = nil
        silenceTask = nil
        levels = []
        spectrum = .silent
        state = .idle
    }

    private static func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default, options: .duckOthers)
        // Sem isso o iOS corta os hápticos enquanto grava.
        try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private nonisolated static func startCapture(on engine: AVAudioEngine, feed: AnalyzerFeed) throws {
        let inputNode = engine.inputNode
        try feed.prepare(from: inputNode.outputFormat(forBus: 0))
        try inputNode.installAudioTap(onBus: 0, bufferSize: 4096, format: nil) { buffer, _ in
            feed.consume(buffer)
        }
        engine.prepare()
        try engine.start()
    }
}

/// Leva o áudio do microfone para o analisador, no formato que ele pede, e mede o volume
/// e as faixas da voz. Roda na thread de áudio; o conversor e os filtros só são usados
/// por ela, por isso o `@unchecked`.
private final class AnalyzerFeed: @unchecked Sendable {
    private let format: AVAudioFormat
    private let input: AsyncStream<AnalyzerInput>.Continuation
    private let readings: AsyncStream<VoiceReading>.Continuation
    private var converter: AVAudioConverter?
    /// Amostras por pedaço de 20 ms.
    private var window = 960
    private var windowSeconds = 0.02
    // Grave perto da fundamental da voz, médio nas vogais, agudo nas consoantes.
    private var low = BandPass(center: 180)
    private var mid = BandPass(center: 700)
    private var high = BandPass(center: 2800)

    init(format: AVAudioFormat, input: AsyncStream<AnalyzerInput>.Continuation, readings: AsyncStream<VoiceReading>.Continuation) {
        self.format = format
        self.input = input
        self.readings = readings
    }

    func prepare(from inputFormat: AVAudioFormat) throws {
        let sampleRate = inputFormat.sampleRate
        window = max(1, Int(sampleRate * 0.02))
        windowSeconds = Double(window) / sampleRate
        low = BandPass(center: 180, sampleRate: sampleRate)
        mid = BandPass(center: 700, sampleRate: sampleRate)
        high = BandPass(center: 2800, sampleRate: sampleRate)

        guard inputFormat != format else { return }
        guard let converter = AVAudioConverter(from: inputFormat, to: format) else {
            throw VoiceRecorderError.unavailable
        }
        self.converter = converter
    }

    func consume(_ readOnly: AVReadOnlyAudioPCMBuffer) {
        if readOnly.frameLength > 0, case let .float(samples) = readOnly.channelData(0) {
            let count = readOnly.frameLength
            var levels: [Double] = []
            var start = 0
            while start < count {
                let end = min(start + window, count)
                var sum: Float = 0
                for index in start..<end {
                    sum += samples[index] * samples[index]
                }
                levels.append(Self.normalized(rms: sqrt(sum / Float(end - start)), floor: -50))
                start = end
            }
            readings.yield(VoiceReading(
                levels: levels,
                spacing: windowSeconds,
                spectrum: VoiceSpectrum(
                    low: Self.normalized(rms: low.rms(of: samples, count: count), floor: -56),
                    mid: Self.normalized(rms: mid.rms(of: samples, count: count), floor: -60),
                    high: Self.normalized(rms: high.rms(of: samples, count: count), floor: -66)
                )
            ))
        }

        let buffer = AVAudioPCMBuffer(copying: readOnly)
        if let converted = convert(buffer) {
            input.yield(AnalyzerInput(buffer: converted))
        }
    }

    private func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let converter else { return buffer }

        let ratio = format.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up))
        guard let output = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return nil }

        var consumed = false
        var error: NSError?
        converter.convert(to: output, error: &error) { _, status in
            if consumed {
                status.pointee = .noDataNow
                return nil
            }
            consumed = true
            status.pointee = .haveData
            return buffer
        }
        return error == nil ? output : nil
    }

    /// RMS em dB, levado para 0...1 numa janela de 40 dB a partir de `floor`.
    private static func normalized(rms: Float, floor: Float) -> Double {
        let decibels = 20 * log10(max(rms, 0.000_001))
        return min(max(Double((decibels - floor) / 40), 0), 1)
    }
}

/// Filtro passa-faixa (biquad do RBJ cookbook). Guarda o estado entre um buffer e outro.
private struct BandPass {
    private let b0: Float
    private let b2: Float
    private let a1: Float
    private let a2: Float
    private var x1: Float = 0
    private var x2: Float = 0
    private var y1: Float = 0
    private var y2: Float = 0

    init(center: Double, sampleRate: Double = 48_000, q: Double = 0.9) {
        let w0 = 2 * Double.pi * center / sampleRate
        let alpha = sin(w0) / (2 * q)
        let a0 = 1 + alpha
        b0 = Float(alpha / a0)
        b2 = Float(-alpha / a0)
        a1 = Float(-2 * cos(w0) / a0)
        a2 = Float((1 - alpha) / a0)
    }

    mutating func rms(of samples: Span<Float>, count: Int) -> Float {
        var sum: Float = 0
        for index in 0..<count {
            let x = samples[index]
            let y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2
            x2 = x1
            x1 = x
            y2 = y1
            y1 = y
            sum += y * y
        }
        return sqrt(sum / Float(count))
    }
}
