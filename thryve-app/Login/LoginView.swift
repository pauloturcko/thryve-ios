import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session

    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty && !isSubmitting
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image("ThryveLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Thryve")
                Text("Fale o que gastou. A Thryve anota.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                TextField("E-mail", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }
                    .modifier(FieldStyle())

                SecureField("Senha", text: $password)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .focused($focusedField, equals: .password)
                    .onSubmit(submit)
                    .modifier(FieldStyle())
            }

            VStack(alignment: .leading, spacing: 12) {
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button(action: submit) {
                    ZStack {
                        Text("Entrar").opacity(isSubmitting ? 0 : 1)
                        if isSubmitting {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSubmit)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onChange(of: email) { errorMessage = nil }
        .onChange(of: password) { errorMessage = nil }
    }

    private func submit() {
        guard canSubmit else { return }
        focusedField = nil
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                try await session.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = (error as? LoginError ?? .unexpected).errorDescription
            }
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(isEnabled ? Color(.systemBackground) : Color.secondary)
            .tint(Color(.systemBackground))
            .frame(minHeight: 52)
            .background(
                isEnabled ? AnyShapeStyle(.primary) : AnyShapeStyle(.fill.tertiary),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct FieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview("Claro") {
    LoginView()
        .environment(SessionStore())
}

#Preview("Escuro") {
    LoginView()
        .environment(SessionStore())
        .preferredColorScheme(.dark)
}
