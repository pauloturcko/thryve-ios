import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            switch session.state {
            case .restoring:
                ProgressView()
            case .signedOut:
                LoginView()
            case let .signedIn(user):
                HomeView(user: user)
            case .restoreFailed:
                ContentUnavailableView {
                    Label("Sem conexão", systemImage: "wifi.slash")
                } description: {
                    Text("Não foi possível falar com o servidor.")
                } actions: {
                    Button("Tentar de novo") {
                        Task { await session.restore() }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Sair", role: .destructive, action: session.signOut)
                }
            }
        }
        .task { await session.restore() }
    }
}
