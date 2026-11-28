import AppIntents
import Foundation

/// Registro de gasto pela Siri. A frase falada segue o mesmo caminho da tela inicial e vira rascunho.
struct RegisterExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Registrar gasto"
    static let description = IntentDescription("Salva um gasto falado como rascunho para revisar depois.")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Gasto", requestValueDialog: "Qual foi o gasto?")
    var phrase: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let tokenStore = TokenStore()
        guard tokenStore.read() != nil else { throw RegisterExpenseIntentError.signedOut }

        let transcript = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else { throw RegisterExpenseIntentError.emptyPhrase }

        let draft: SavedExpenseDraft
        do {
            draft = try await ExpenseDraftService(client: APIClient.make(tokenStore: tokenStore)).save(transcript: transcript)
        } catch ExpenseDraftError.sessionExpired {
            throw RegisterExpenseIntentError.signedOut
        } catch {
            throw RegisterExpenseIntentError.failed(error as? ExpenseDraftError ?? .unexpected)
        }

        return .result(dialog: Self.dialog(for: draft))
    }

    private static func dialog(for draft: SavedExpenseDraft) -> IntentDialog {
        guard let amount = draft.amount else {
            return "Anotei o gasto, mas não entendi o valor. Ele ficou nos rascunhos para você revisar."
        }

        let value = amount.formatted(.currency(code: "BRL").locale(Locale(identifier: "pt_BR")))
        guard let description = draft.description else {
            return "Anotado: \(value). Ficou nos rascunhos para revisar."
        }
        return "Anotado: \(value) em \(description). Ficou nos rascunhos para revisar."
    }
}

enum RegisterExpenseIntentError: Error, CustomLocalizedStringResourceConvertible {
    case signedOut
    case emptyPhrase
    case failed(ExpenseDraftError)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .signedOut: "Abra o Thryve e entre na sua conta primeiro."
        case .emptyPhrase: "Não ouvi nenhum gasto. Tente de novo."
        case let .failed(error): "\(error.errorDescription ?? "Não foi possível salvar o gasto.")"
        }
    }
}
