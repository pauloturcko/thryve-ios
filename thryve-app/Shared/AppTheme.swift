import SwiftUI

/// Tema escolhido no app. O padrão é escuro, com a bolinha branca.
enum AppTheme: String {
    case dark
    case light

    static let storageKey = "appTheme"

    var colorScheme: ColorScheme {
        switch self {
        case .dark: .dark
        case .light: .light
        }
    }

    var toggled: AppTheme {
        self == .dark ? .light : .dark
    }
}
