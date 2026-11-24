import Foundation

struct ExplicitMentions {
    private(set) var daysAgo: Int?
    private(set) var paymentMethodId: Int?
    private(set) var cardId: Int?
    private(set) var accountId: Int?
    private(set) var amount: Decimal?

    private static let genericWords: Set<String> = [
        "cartao", "card", "bank", "banco", "conta", "corrente", "poupanca", "credito", "debito", "de", "do", "da", "e",
    ]

    private static let paymentSlugsByWord: [String: String] = [
        "pix": "pix",
        "boleto": "bank_slip",
        "dinheiro": "cash",
        "especie": "cash",
        "debito": "debit_card",
        "credito": "credit_card",
    ]

    init(transcript: String, context: ExpenseContext) {
        let words = Self.words(in: transcript)

        if words.contains("anteontem") {
            daysAgo = 2
        } else if words.contains("ontem") {
            daysAgo = 1
        } else if words.contains("hoje") {
            daysAgo = 0
        }

        let cardMatches = context.cards.filter { card in
            words.contains(card.lastFourDigits) || !Self.significantWords(in: card.name).isDisjoint(with: words)
        }
        if cardMatches.count == 1 {
            cardId = cardMatches[0].id
        }

        if cardId == nil {
            let accountMatches = context.accounts.filter { !Self.significantWords(in: $0.name).isDisjoint(with: words) }
            if accountMatches.count == 1 {
                accountId = accountMatches[0].id
            }
        }

        let slugs = Set(words.compactMap { Self.paymentSlugsByWord[$0] })
        if slugs.count == 1, let slug = slugs.first {
            paymentMethodId = context.paymentMethod(slug: slug)?.id
        } else if slugs.isEmpty, let card = cardMatches.first, cardMatches.count == 1 {
            switch card.kind {
            case .credit: paymentMethodId = context.paymentMethod(slug: "credit_card")?.id
            case .debit: paymentMethodId = context.paymentMethod(slug: "debit_card")?.id
            case .creditAndDebit, nil: break
            }
        }

        let cardDigits = Set(context.cards.map(\.lastFourDigits))
        amount = Self.amount(in: transcript, ignoring: cardDigits)
    }

    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
    }

    private static func words(in text: String) -> Set<String> {
        Set(normalized(text).split { !$0.isLetter && !$0.isNumber }.map(String.init))
    }

    private static func significantWords(in name: String) -> Set<String> {
        words(in: name).filter { $0.count >= 2 && !genericWords.contains($0) }
    }

    private static func amount(in text: String, ignoring cardDigits: Set<String>) -> Decimal? {
        let pattern = /(?:^|[^\p{L}\d.,])(\d{1,3}(?:\.\d{3})+|\d+)(?:,(\d{1,2}))?(?![\p{L}\d])/
        for match in text.matches(of: pattern) {
            let integer = String(match.output.1).replacingOccurrences(of: ".", with: "")
            guard !cardDigits.contains(integer) else { continue }

            let cents = match.output.2.map(String.init) ?? "0"
            if let value = Decimal(string: "\(integer).\(cents)", locale: Locale(identifier: "en_US_POSIX")), value > 0 {
                return value
            }
        }
        return nil
    }
}
