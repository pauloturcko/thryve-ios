import Foundation

struct ExpenseContext: Sendable {
    struct Card: Sendable {
        enum Kind: Int, Sendable {
            case credit = 1
            case debit = 2
            case creditAndDebit = 3
        }

        let id: Int
        let name: String
        let lastFourDigits: String
        let kind: Kind?
    }

    struct Account: Sendable {
        let id: Int
        let name: String
    }

    struct Category: Sendable {
        let id: Int
        let name: String
    }

    struct PaymentMethod: Sendable {
        let id: Int
        let name: String
        let slug: String
    }

    let cards: [Card]
    let accounts: [Account]
    let categories: [Category]
    let paymentMethods: [PaymentMethod]

    init(_ response: Components.Schemas.ExpenseDraftContextResponse) {
        cards = response.cards.map {
            Card(id: $0.id, name: $0.name, lastFourDigits: $0.lastFourDigits, kind: Card.Kind(rawValue: $0.cardType))
        }
        accounts = response.bankAccounts.map { Account(id: $0.id, name: $0.name) }
        categories = response.categories.map { Category(id: $0.id, name: $0.name) }
        paymentMethods = response.paymentMethods.map { PaymentMethod(id: $0.id, name: $0.name, slug: $0.slug) }
    }

    func paymentMethod(slug: String) -> PaymentMethod? {
        paymentMethods.first { $0.slug == slug }
    }
}
