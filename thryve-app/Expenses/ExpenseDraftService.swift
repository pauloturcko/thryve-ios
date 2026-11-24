import Foundation
import OpenAPIRuntime

enum ExpenseDraftError: LocalizedError {
    case sessionExpired
    case connection
    case unexpected

    var errorDescription: String? {
        switch self {
        case .sessionExpired: "Sua sessão expirou. Entre de novo."
        case .connection: "Não foi possível conectar. Verifique sua internet."
        case .unexpected: "Não foi possível salvar o gasto. Tente de novo."
        }
    }
}

struct SavedExpenseDraft: Sendable {
    let transcript: String
    let amount: Decimal?
    let description: String?
    let date: Date
    let categoryName: String?
    let cardName: String?
    let accountName: String?
    let paymentMethodName: String?
    let usedModel: Bool
}

struct ExpenseDraftService: Sendable {
    let client: Client

    func save(transcript: String) async throws -> SavedExpenseDraft {
        let context = try await loadContext()
        let mentions = ExplicitMentions(transcript: transcript, context: context)

        var interpreted: ExpenseInterpreter.Result?
        if ExpenseInterpreter.isAvailable {
            interpreted = try? await ExpenseInterpreter().interpret(transcript, categories: context.categories)
        }

        let amount = interpreted?.amount ?? mentions.amount
        let date = Calendar.current.date(byAdding: .day, value: -(mentions.daysAgo ?? 0), to: .now) ?? .now

        let input = Components.Schemas.ExpenseDraftInput(
            transcript: transcript,
            description: interpreted?.description,
            amount: amount.map(Self.apiAmount),
            date: Self.apiDate(date),
            expenseKind: ._1,
            categoryId: interpreted?.categoryId,
            bankAccountId: mentions.accountId,
            paymentMethodId: mentions.paymentMethodId,
            cardId: mentions.cardId
        )
        try await register(input)

        return SavedExpenseDraft(
            transcript: transcript,
            amount: amount,
            description: input.description,
            date: date,
            categoryName: context.categories.first { $0.id == input.categoryId }?.name,
            cardName: context.cards.first { $0.id == input.cardId }?.name,
            accountName: context.accounts.first { $0.id == input.bankAccountId }?.name,
            paymentMethodName: context.paymentMethods.first { $0.id == input.paymentMethodId }?.name,
            usedModel: interpreted != nil
        )
    }

    private func loadContext() async throws -> ExpenseContext {
        switch try await call({ try await client.getExpenseDraftsContext() }) {
        case let .ok(response):
            guard let body = try? response.body.json else { throw ExpenseDraftError.unexpected }
            return ExpenseContext(body)
        case .unauthorized:
            throw ExpenseDraftError.sessionExpired
        case .undocumented:
            throw ExpenseDraftError.unexpected
        }
    }

    private func register(_ input: Components.Schemas.ExpenseDraftInput) async throws {
        switch try await call({ try await client.postExpenseDraftsRegister(body: .json(input)) }) {
        case .created:
            return
        case .unauthorized:
            throw ExpenseDraftError.sessionExpired
        default:
            throw ExpenseDraftError.unexpected
        }
    }

    private func call<Output>(_ operation: () async throws -> Output) async throws -> Output {
        do {
            return try await operation()
        } catch let error as ClientError where error.underlyingError is URLError {
            throw ExpenseDraftError.connection
        } catch {
            throw ExpenseDraftError.unexpected
        }
    }

    private static func apiAmount(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private static func apiDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
