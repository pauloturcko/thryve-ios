import Foundation
import FoundationModels

struct ExpenseInterpreter {
    struct Result {
        var amount: Decimal?
        var description: String?
        var categoryId: Int?
    }

    private static let noCategory = "Nenhuma"

    private static let instructions = """
        Você extrai um gasto de uma frase falada em português do Brasil. \
        Não invente: se a frase não disser, use o valor vazio indicado.
        """

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func interpret(_ transcript: String, categories: [ExpenseContext.Category]) async throws -> Result {
        let names = Array(Set(categories.map(\.name)).subtracting([Self.noCategory])).sorted()
        let category = DynamicGenerationSchema(name: "Categoria", anyOf: [Self.noCategory] + names)
        let expense = DynamicGenerationSchema(name: "Gasto", properties: [
            .init(
                name: "valor",
                description: "Valor gasto em reais, só o número com ponto decimal (ex.: 23.9 para 'vinte e três e noventa'). 0 se a frase não disser um valor.",
                schema: DynamicGenerationSchema(type: Double.self)
            ),
            .init(
                name: "descricao",
                description: "Onde ou com o que gastou, curto, como foi dito (ex.: Mercado, Uber, Farmácia, Luz). Vazio se não disser.",
                schema: DynamicGenerationSchema(type: String.self)
            ),
            .init(
                name: "categoria",
                description: "Categoria da lista à qual o gasto pertence. Se nenhuma for exatamente o tipo desse gasto, Nenhuma. Prefira Nenhuma a uma categoria só parecida.",
                schema: category
            ),
        ])
        let schema = try GenerationSchema(root: expense, dependencies: [category])

        let session = LanguageModelSession(instructions: Self.instructions)
        let content = try await session.respond(
            to: "Frase: \(transcript)",
            schema: schema,
            options: GenerationOptions(samplingMode: .greedy)
        ).content

        let amount = (try? content.value(Double.self, forProperty: "valor")).flatMap(Self.amount)
        let description = (try? content.value(String.self, forProperty: "descricao")).flatMap(Self.description)
        let categoryName = try? content.value(String.self, forProperty: "categoria")

        return Result(
            amount: amount,
            description: description,
            categoryId: categories.first { $0.name == categoryName }?.id
        )
    }

    private static func amount(_ value: Double) -> Decimal? {
        guard value > 0, value.isFinite else { return nil }
        return Decimal(string: String(format: "%.2f", value), locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func description(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.caseInsensitiveCompare(noCategory) != .orderedSame else { return nil }

        let lowercased = trimmed.lowercased(with: Locale(identifier: "pt_BR"))
        return String(lowercased.prefix(1).uppercased() + lowercased.dropFirst()).prefix(150).description
    }
}
