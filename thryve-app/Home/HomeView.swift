import SwiftUI

/// Tela provisória depois do login. Enquanto o reconhecimento de voz não existe, a frase é digitada aqui;
/// o resto do caminho (interpretar e salvar o rascunho) já é o definitivo.
struct HomeView: View {
    @Environment(SessionStore.self) private var session

    let user: AuthenticatedUser

    @State private var transcript = ""
    @State private var isSaving = false
    @State private var saved: SavedExpenseDraft?
    @State private var errorMessage: String?

    private var canSave: Bool {
        !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Olá, \(user.firstName)")
                        .font(.title.weight(.semibold))
                    Text("Escreva o gasto como você falaria.")
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    TextField("Ex.: gastei 10 reais no mercado no cartão do C6", text: $transcript, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(.vertical, 14)
                        .modifier(FieldStyle())

                    Button(action: save) {
                        ZStack {
                            Text("Salvar gasto").opacity(isSaving ? 0 : 1)
                            if isSaving {
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canSave)
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let saved {
                    SavedDraftSummary(draft: saved)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button("Sair", role: .destructive, action: session.signOut)
                .padding(.bottom, 8)
        }
    }

    private func save() {
        guard canSave else { return }
        let phrase = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        isSaving = true
        errorMessage = nil
        Task {
            defer { isSaving = false }
            do {
                saved = try await ExpenseDraftService(client: session.client).save(transcript: phrase)
                transcript = ""
            } catch ExpenseDraftError.sessionExpired {
                session.signOut()
            } catch {
                errorMessage = (error as? ExpenseDraftError ?? .unexpected).errorDescription
            }
        }
    }
}

private struct SavedDraftSummary: View {
    let draft: SavedExpenseDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Salvo para revisão", systemImage: "checkmark.circle.fill")
                .font(.headline)

            Text("“\(draft.transcript)”")
                .foregroundStyle(.secondary)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                row("Valor", draft.amount.map { $0.formatted(.currency(code: "BRL").locale(Locale(identifier: "pt_BR"))) })
                row("Descrição", draft.description)
                row("Data", draft.date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "pt_BR"))))
                row("Categoria", draft.categoryName)
                row("Cartão", draft.cardName)
                row("Conta", draft.accountName)
                row("Pagamento", draft.paymentMethodName)
            }
            .font(.subheadline)

            if !draft.usedModel {
                Text("Apple Intelligence indisponível neste aparelho: só o valor em algarismos foi preenchido.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func row(_ label: String, _ value: String?) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value ?? "—")
                .foregroundStyle(value == nil ? .tertiary : .primary)
        }
    }
}

#Preview {
    HomeView(user: AuthenticatedUser(.init(id: 1, name: "Paulo Turco", email: "teste@thryve.dev"))!)
        .environment(SessionStore())
}
