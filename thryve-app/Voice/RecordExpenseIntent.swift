import AppIntents
import Observation

/// Pedido para abrir o app já gravando. O Botão de Ação e a Siri chegam aqui pelo `RecordExpenseIntent`.
@MainActor
@Observable
final class RecordingRequest {
    static let shared = RecordingRequest()

    var isPending = false
}

struct RecordExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Gravar gasto"
    static let description = IntentDescription("Abre o Thryve já ouvindo, para você falar o gasto.")
    static let supportedModes: IntentModes = .foreground

    func perform() async throws -> some IntentResult {
        await MainActor.run { RecordingRequest.shared.isPending = true }
        return .result()
    }
}
