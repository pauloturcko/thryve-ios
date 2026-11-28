import MetalKit
import simd

/// Em que momento a bolinha está. Cada estado tem um peso no shader, que entra e sai suave.
enum OrbState: Equatable {
    case idle
    case listening
    case processing
    case saved
}

/// Espelho do `OrbUniforms` do `Orb.metal`. Só `Float`, na mesma ordem.
private struct OrbUniforms {
    var width: Float
    var height: Float
    var scale: Float
    var time: Float
    var phase: Float
    var energy: Float
    var low: Float
    var mid: Float
    var high: Float
    var pulseAge: Float
    var pulseAmp: Float
    var listen: Float
    var process: Float
    var saved: Float
    var light: Float
}

/// Uma onda do campo de correntes da poeira.
private struct FlowWave {
    let direction: SIMD2<Float>
    let amplitude: Float
    let rate: Float
    let phase: Float
}

/// Um grão de poeira. Anda levado pelas correntes e também por conta própria, mudando de
/// rumo ao acaso, então cada um vai para um lado.
private struct Grain {
    var position: SIMD2<Float>
    var heading: Float
    let pace: Float
    /// Diâmetro em pontos.
    let size: Float
    let brightness: Float
    let depthRate: Float
    let depthPhase: Float
}

/// Desenha a orb elétrica na GPU, no ritmo da tela: a poeira primeiro, a borda por cima.
///
/// O microfone entrega um lote de volumes a cada ~85 ms, um a cada 20 ms de áudio. Em vez de
/// pular para o último, o lote é tocado no relógio da tela, um volume por vez: assim a bolinha
/// acompanha as sílabas em vez de andar aos trancos.
///
/// A poeira segue um campo de correntes sem divergência (curl noise), que forma redemoinhos
/// em sentidos diferentes sem amontoar os grãos, mais um passeio aleatório de cada grão.
@MainActor
final class OrbRenderer: NSObject, MTKViewDelegate {
    var spectrum = VoiceSpectrum.silent
    var isLight = false
    var state = OrbState.idle {
        didSet {
            guard state != oldValue else { return }
            stateSince = clock
            if state != .listening { scheduled.removeAll() }
        }
    }

    /// Quanto tempo o ✓ fica aceso depois de salvar.
    private static let savedHold = 2.0
    /// Fila máxima: se a tela travar, descarta o atraso em vez de acumular.
    private static let maxBacklog = 0.25
    private static let grainCount = 2000
    /// Até onde a poeira vai, em raios da esfera.
    private static let reach: Float = 0.96
    private static let framesInFlight = 3

    /// Somadas, formam as correntes. Direções variadas: cada região gira para um lado.
    private static let flow: [FlowWave] = [
        FlowWave(direction: SIMD2(2.3, 1.1), amplitude: 0.30, rate: 0.7, phase: 0.3),
        FlowWave(direction: SIMD2(-1.4, 2.8), amplitude: 0.26, rate: -0.9, phase: 1.9),
        FlowWave(direction: SIMD2(3.6, -2.4), amplitude: 0.16, rate: 1.3, phase: 4.1),
        FlowWave(direction: SIMD2(-1.1, -4.2), amplitude: 0.13, rate: -1.1, phase: 2.7),
        FlowWave(direction: SIMD2(5.1, 3.3), amplitude: 0.07, rate: 1.7, phase: 5.3),
    ]

    private let queue: MTLCommandQueue
    private let rimPipeline: MTLRenderPipelineState
    private let dustPipeline: MTLRenderPipelineState
    private let grainBuffers: [MTLBuffer]
    private let frameSlots = DispatchSemaphore(value: framesInFlight)
    private var frameIndex = 0
    private var grains: [Grain]
    private var flowTime: Float = 0
    private var randomState: UInt32 = 0x9E37_79B9

    private var scheduled: [(time: Double, level: Double)] = []
    private var targetEnergy = 0.0
    private var shownEnergy = 0.0
    private var shownSpectrum = SIMD3<Double>(repeating: 0)
    private var averageLevel = 0.0
    private var phase = 0.0
    private var pulseAge = 9.0
    private var pulseAmp = 0.0
    private var listen = 0.0
    private var process = 0.0
    private var saved = 0.0
    private var clock = 0.0
    private var stateSince = 0.0
    private var lastFrame: CFTimeInterval?

    init?(view: MTKView) {
        guard let device = view.device,
              let queue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary()
        else { return nil }

        func pipeline(vertex: String, fragment: String) -> MTLRenderPipelineState? {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = library.makeFunction(name: vertex)
            descriptor.fragmentFunction = library.makeFunction(name: fragment)
            guard let attachment = descriptor.colorAttachments[0] else { return nil }
            attachment.pixelFormat = view.colorPixelFormat
            // Os shaders devolvem cor já multiplicada pelo alfa.
            attachment.isBlendingEnabled = true
            attachment.sourceRGBBlendFactor = .one
            attachment.sourceAlphaBlendFactor = .one
            attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            return try? device.makeRenderPipelineState(descriptor: descriptor)
        }

        let bufferLength = MemoryLayout<SIMD4<Float>>.stride * Self.grainCount
        let buffers = (0..<Self.framesInFlight).compactMap { _ in
            device.makeBuffer(length: bufferLength, options: .storageModeShared)
        }
        guard let rimPipeline = pipeline(vertex: "orbQuadVertex", fragment: "orbElectricFragment"),
              let dustPipeline = pipeline(vertex: "orbDustVertex", fragment: "orbDustFragment"),
              buffers.count == Self.framesInFlight
        else { return nil }

        self.queue = queue
        self.rimPipeline = rimPipeline
        self.dustPipeline = dustPipeline
        grainBuffers = buffers
        grains = Self.makeGrains()
    }

    /// Agenda um lote de volumes do microfone, espaçados de `spacing` segundos.
    func enqueue(levels: [Double], spacing: Double) {
        guard state == .listening, !levels.isEmpty else { return }
        var start = max(clock, scheduled.last?.time ?? clock)
        if start - clock > Self.maxBacklog {
            scheduled.removeAll()
            start = clock
        }
        for (index, level) in levels.enumerated() {
            scheduled.append((start + spacing * Double(index + 1), level))
        }
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        let elapsed = lastFrame.map { min(now - $0, 0.1) } ?? 0
        lastFrame = now
        clock += elapsed
        advance(by: elapsed)
        moveGrains(by: Float(elapsed))

        frameSlots.wait()
        frameIndex = (frameIndex + 1) % Self.framesInFlight
        let grainBuffer = grainBuffers[frameIndex]
        writeGrains(into: grainBuffer)

        guard let pass = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commands = queue.makeCommandBuffer(),
              let encoder = commands.makeRenderCommandEncoder(descriptor: pass)
        else {
            frameSlots.signal()
            return
        }

        var uniforms = OrbUniforms(
            width: Float(view.drawableSize.width),
            height: Float(view.drawableSize.height),
            scale: Float(view.contentScaleFactor),
            time: Float(clock.truncatingRemainder(dividingBy: 3600)),
            phase: Float(phase.truncatingRemainder(dividingBy: 1000)),
            energy: Float(shownEnergy),
            low: Float(shownSpectrum.x),
            mid: Float(shownSpectrum.y),
            high: Float(shownSpectrum.z),
            pulseAge: Float(pulseAge),
            pulseAmp: Float(pulseAmp),
            listen: Float(listen),
            process: Float(process),
            saved: Float(saved),
            light: isLight ? 1 : 0
        )
        let uniformsSize = MemoryLayout<OrbUniforms>.stride

        encoder.setRenderPipelineState(dustPipeline)
        encoder.setVertexBuffer(grainBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&uniforms, length: uniformsSize, index: 1)
        encoder.setFragmentBytes(&uniforms, length: uniformsSize, index: 0)
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: Self.grainCount)

        encoder.setRenderPipelineState(rimPipeline)
        encoder.setFragmentBytes(&uniforms, length: uniformsSize, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        let slots = frameSlots
        commands.addCompletedHandler { _ in slots.signal() }
        commands.present(drawable)
        commands.commit()
    }

    private func advance(by elapsed: Double) {
        func follow(_ value: inout Double, to target: Double, up: Double, down: Double) {
            value += (target - value) * min(elapsed * (target > value ? up : down), 1)
        }

        // Toca os volumes que já chegaram na hora deles.
        while let next = scheduled.first, next.time <= clock {
            scheduled.removeFirst()
            play(level: next.level)
        }
        if state != .listening { targetEnergy = 0 }
        pulseAge += elapsed

        follow(&shownEnergy, to: targetEnergy, up: 18, down: 5)
        let bands = state == .listening ? SIMD3(spectrum.low, spectrum.mid, spectrum.high) : SIMD3(repeating: 0)
        follow(&shownSpectrum.x, to: bands.x, up: 12, down: 4)
        follow(&shownSpectrum.y, to: bands.y, up: 12, down: 4)
        follow(&shownSpectrum.z, to: bands.z, up: 12, down: 4)

        follow(&listen, to: state == .listening ? 1 : 0, up: 8, down: 3)
        follow(&process, to: state == .processing ? 1 : 0, up: 6, down: 4)
        let showsCheck = state == .saved && clock - stateSince < Self.savedHold
        follow(&saved, to: showsCheck ? 1 : 0, up: 7, down: 3)

        phase += elapsed * (0.25 + 2.2 * shownEnergy * listen)
    }

    private func play(level: Double) {
        targetEnergy = level
        // Sílaba: o volume pulou acima da média recente.
        if level - averageLevel > 0.12, pulseAge > 0.12 {
            pulseAge = 0
            pulseAmp = min(1, 0.5 + level)
        }
        averageLevel += (level - averageLevel) * 0.3
    }

    private func moveGrains(by elapsed: Float) {
        let active = Float(shownEnergy * listen)
        let high = Float(shownSpectrum.z * listen)
        let processing = Float(process)
        // Parada, a poeira flutua devagar; com a voz, as correntes aceleram e embaralham.
        let flowSpeed = 0.06 + 0.45 * active + 0.25 * processing
        let wanderSpeed = 0.03 + 0.14 * active
        let turnRate = 3.0 * (1 + 3 * high)
        flowTime += elapsed * (0.2 + 1.2 * active + 0.8 * processing)

        let reachSquared = Self.reach * Self.reach
        for index in grains.indices {
            var grain = grains[index]
            let point = grain.position

            // Corrente ψ = soma das ondas × (1 − r²/reach²), que zera na borda. A velocidade é o
            // gradiente girado 90°: não amontoa e corre paralela à borda.
            var stream: Float = 0
            var gradient = SIMD2<Float>(repeating: 0)
            for wave in Self.flow {
                let argument = simd_dot(wave.direction, point) + wave.rate * flowTime + wave.phase
                stream += wave.amplitude * sin(argument)
                gradient += wave.direction * (wave.amplitude * cos(argument))
            }
            let envelope = 1 - simd_length_squared(point) / reachSquared
            let shaped = gradient * envelope + point * (-2 * stream / reachSquared)
            let current = SIMD2(shaped.y, -shaped.x) * flowSpeed

            // Passeio próprio: o rumo muda ao acaso, cada grão para um lado.
            grain.heading += (nextRandom() - 0.5) * turnRate * elapsed * 2
            let own = SIMD2(cos(grain.heading), sin(grain.heading)) * (wanderSpeed * grain.pace)

            var moved = point + (current + own) * elapsed
            let distance = simd_length(moved)
            if distance > Self.reach {
                // Bateu na borda: volta para dentro e vira o rumo.
                moved *= (2 * Self.reach - distance) / distance
                grain.heading += .pi
            }
            grain.position = moved
            grains[index] = grain
        }
    }

    private func writeGrains(into buffer: MTLBuffer) {
        let time = Float(clock.truncatingRemainder(dividingBy: 3600))
        let active = Float(shownEnergy * listen)
        let target = buffer.contents().bindMemory(to: SIMD4<Float>.self, capacity: Self.grainCount)
        for index in grains.indices {
            let grain = grains[index]
            // Profundidade: os grãos "da frente" ficam maiores e mais claros.
            let depth = 0.5 + 0.5 * sin(time * grain.depthRate + grain.depthPhase)
            let twinkle = 0.85 + 0.15 * sin(time * (1.3 + grain.depthRate * 3) + grain.depthPhase * 7)
            let size = grain.size * (0.75 + 0.5 * depth)
            let brightness = grain.brightness * (0.45 + 0.55 * depth) * twinkle * (0.85 + 0.4 * active)
            target[index] = SIMD4(grain.position.x, grain.position.y, size, brightness)
        }
    }

    /// Número aleatório de 0 a 1 (xorshift): barato o bastante para rodar a cada quadro.
    private func nextRandom() -> Float {
        randomState ^= randomState << 13
        randomState ^= randomState >> 17
        randomState ^= randomState << 5
        return Float(randomState) / Float(UInt32.max)
    }

    private static func makeGrains() -> [Grain] {
        var random = SystemRandomNumberGenerator()
        let unit = { (random: inout SystemRandomNumberGenerator) in Float.random(in: 0...1, using: &random) }
        return (0..<grainCount).map { _ in
            let radius = reach * sqrt(unit(&random))
            let angle = unit(&random) * 2 * .pi
            // Muitos grãos minúsculos, alguns pequenos e poucos maiores, como poeira de verdade.
            let sizeRoll = unit(&random)
            let size = 0.6 + 2.8 * pow(sizeRoll, 3.5)
            return Grain(
                position: SIMD2(radius * cos(angle), radius * sin(angle)),
                heading: unit(&random) * 2 * .pi,
                pace: 0.4 + 1.2 * unit(&random),
                size: size,
                brightness: min(1, 0.35 + 0.5 * pow(unit(&random), 1.5) + 0.25 * sizeRoll),
                depthRate: 0.15 + 0.5 * unit(&random),
                depthPhase: unit(&random) * 2 * .pi
            )
        }
    }
}
