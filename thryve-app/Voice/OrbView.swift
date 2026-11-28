import MetalKit
import SwiftUI

/// Um lote de leituras do microfone para a bolinha: volumes a cada `spacing` segundos
/// e as faixas da voz. `sequence` muda a cada lote novo.
struct OrbVoice: Equatable {
    var levels: [Double] = []
    var spacing = 0.02
    var sequence = 0
    var spectrum = VoiceSpectrum.silent

    static let silent = OrbVoice()
}

/// A bolinha da tela de gravação. O desenho é todo na GPU (`OrbRenderer` + `Orb.metal`).
struct OrbView: View {
    var state: OrbState
    var voice: OrbVoice

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        OrbMetalView(state: state, voice: voice, isLight: colorScheme == .light)
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

private struct OrbMetalView: UIViewRepresentable {
    var state: OrbState
    var voice: OrbVoice
    var isLight: Bool

    final class Coordinator {
        var renderer: OrbRenderer?
        var lastSequence = -1
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.framebufferOnly = true
        view.isUserInteractionEnabled = false

        let renderer = OrbRenderer(view: view)
        context.coordinator.renderer = renderer
        view.delegate = renderer
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        renderer.state = state
        renderer.isLight = isLight
        renderer.spectrum = voice.spectrum
        if voice.sequence != context.coordinator.lastSequence {
            context.coordinator.lastSequence = voice.sequence
            renderer.enqueue(levels: voice.levels, spacing: voice.spacing)
        }
        // 120 Hz só enquanto ouve; parada, 60 Hz basta e poupa bateria.
        view.preferredFramesPerSecond = state == .listening ? 120 : 60
    }
}
