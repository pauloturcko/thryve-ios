import SwiftUI

/// Tela provisória depois do login. É aqui que entra o botão de registro por voz.
struct HomeView: View {
    @Environment(SessionStore.self) private var session

    let user: AuthenticatedUser

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Olá, \(user.firstName)")
                .font(.title.weight(.semibold))
            Text(user.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Sair", role: .destructive, action: session.signOut)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
    }
}
