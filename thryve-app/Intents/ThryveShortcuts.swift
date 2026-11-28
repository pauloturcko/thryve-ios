import AppIntents

/// Frases que a Siri reconhece sem configuração. Toda frase precisa citar o nome do app.
struct ThryveShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RegisterExpenseIntent(),
            phrases: [
                "Registrar gasto no \(.applicationName)",
                "Registra um gasto no \(.applicationName)",
                "Anotar gasto no \(.applicationName)",
                "Anota um gasto no \(.applicationName)",
                "Novo gasto no \(.applicationName)",
            ],
            shortTitle: "Registrar gasto",
            systemImageName: "text.bubble.fill"
        )
        AppShortcut(
            intent: RecordExpenseIntent(),
            phrases: [
                "Gravar gasto no \(.applicationName)",
                "Abrir gravação no \(.applicationName)",
            ],
            shortTitle: "Gravar gasto",
            systemImageName: "mic.fill"
        )
    }
}
