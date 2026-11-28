import SwiftUI

/// A única tela do app: tocar na bolinha e falar o gasto, ou digitar no campo de baixo.
/// O que entra aqui vira rascunho para revisar no Thryve web.
struct HomeView: View {
    @Environment(SessionStore.self) private var session
    @AppStorage(AppTheme.storageKey) private var theme = AppTheme.dark

    let user: AuthenticatedUser

    @State private var recorder = VoiceRecorder()
    @State private var typed = ""
    @State private var savingPhrase: String?
    @State private var saved: SavedExpenseDraft?
    @State private var savedCount = 0
    @State private var message: String?
    @FocusState private var isTyping: Bool

    private let recordingRequest = RecordingRequest.shared

    private var isBusy: Bool {
        recorder.state != .idle || savingPhrase != nil
    }

    private var canSendTyped: Bool {
        !typed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isBusy
    }

    /// A bolinha só mostra "ouvindo" com o microfone aberto de fato, nunca só pelo toque.
    private var orbState: OrbState {
        switch recorder.state {
        case .listening: .listening
        case .finishing: .processing
        case .preparing: .idle
        case .idle: savingPhrase != nil ? .processing : saved != nil ? .saved : .idle
        }
    }

    private var orbVoice: OrbVoice {
        guard recorder.state == .listening else { return .silent }
        return OrbVoice(
            levels: recorder.levels,
            spacing: recorder.levelSpacing,
            sequence: recorder.levelSequence,
            spectrum: recorder.spectrum
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 0)

            Button(action: toggleRecording) {
                // A view Metal não recebe toque; quem recebe é o botão, pela área do círculo.
                OrbView(state: orbState, voice: orbVoice)
                    .allowsHitTesting(false)
                    .frame(maxWidth: 340)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(recorder.state == .listening ? "Parar e salvar o gasto" : "Gravar gasto")
            .disabled(savingPhrase != nil || recorder.state == .preparing || recorder.state == .finishing)

            status
                .frame(maxWidth: .infinity, minHeight: 110, alignment: .top)
                .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture { isTyping = false }
        .safeAreaInset(edge: .bottom) { inputBar }
        .sensoryFeedback(.impact(weight: .light), trigger: recorder.state == .listening)
        .sensoryFeedback(.success, trigger: savedCount)
        .task {
            recorder.onAutoStop = { Task { await finishRecording() } }
        }
        .onChange(of: recordingRequest.isPending, initial: true) { _, isPending in
            guard isPending else { return }
            recordingRequest.isPending = false
            if recorder.state == .idle { startRecording() }
        }
        .onDisappear {
            Task { await recorder.cancel() }
        }
    }

    private var header: some View {
        HStack {
            Image("ThryveLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 22)
                .foregroundStyle(.primary)
                .accessibilityLabel("Thryve")

            Spacer()

            Menu {
                Text("Olá, \(user.firstName)")
                Button {
                    theme = theme.toggled
                } label: {
                    theme == .dark
                        ? Label("Tema claro", systemImage: "sun.max")
                        : Label("Tema escuro", systemImage: "moon")
                }
                Button("Sair", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: session.signOut)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .tint(.primary)
            .accessibilityLabel("Opções")
        }
        .padding(.leading, 24)
        .padding(.trailing, 12)
        .padding(.top, 4)
    }

    @ViewBuilder
    private var status: some View {
        VStack(spacing: 8) {
            if recorder.state == .preparing {
                hint("Preparando o microfone…")
            } else if recorder.state == .listening {
                if recorder.transcript.isEmpty {
                    hint("Pode falar…")
                } else {
                    phrase(recorder.transcript)
                }
            } else if let savingPhrase {
                phrase(savingPhrase)
                hint("Salvando…")
            } else if recorder.state == .finishing {
                phrase(recorder.transcript)
            } else if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if let saved {
                Label("Salvo para revisar no Thryve", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                hint(summary(of: saved))
            } else {
                hint("Toque e diga o que você gastou")
            }
        }
        .animation(.easeOut(duration: 0.2), value: recorder.transcript)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Ou digite o gasto…", text: $typed)
                .focused($isTyping)
                .submitLabel(.send)
                .onSubmit(sendTyped)

            Button(action: sendTyped) {
                Image(systemName: "arrow.up")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(width: 34, height: 34)
                    .background(canSendTyped ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary), in: Circle())
            }
            .disabled(!canSendTyped)
            .accessibilityLabel("Salvar gasto")
        }
        .padding(.leading, 18)
        .padding(.trailing, 6)
        .frame(minHeight: 48)
        .background(.fill.tertiary, in: Capsule())
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .disabled(recorder.state != .idle)
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    private func phrase(_ text: String) -> some View {
        Text("“\(text)”")
            .font(.title3.weight(.medium))
            .multilineTextAlignment(.center)
            .lineLimit(4)
    }

    private func summary(of draft: SavedExpenseDraft) -> String {
        let parts = [
            draft.amount.map { $0.formatted(.currency(code: "BRL").locale(Locale(identifier: "pt_BR"))) },
            draft.description,
            draft.cardName ?? draft.accountName,
        ].compactMap(\.self)
        return parts.isEmpty ? "Complete os dados no Thryve web" : parts.joined(separator: " · ")
    }

    private func toggleRecording() {
        switch recorder.state {
        case .idle: startRecording()
        case .listening: Task { await finishRecording() }
        case .preparing, .finishing: break
        }
    }

    private func startRecording() {
        isTyping = false
        saved = nil
        message = nil
        Task {
            do {
                try await recorder.start()
            } catch {
                message = (error as? VoiceRecorderError ?? .unavailable).errorDescription
            }
        }
    }

    private func finishRecording() async {
        let phrase = await recorder.stop()
        guard !phrase.isEmpty else {
            message = "Não ouvi nada. Toque e fale de novo."
            return
        }
        await save(phrase)
    }

    private func sendTyped() {
        guard canSendTyped else { return }
        let phrase = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        typed = ""
        isTyping = false
        saved = nil
        message = nil
        Task { await save(phrase) }
    }

    private func save(_ phrase: String) async {
        savingPhrase = phrase
        defer { savingPhrase = nil }
        do {
            saved = try await ExpenseDraftService(client: session.client).save(transcript: phrase)
            savedCount += 1
        } catch ExpenseDraftError.sessionExpired {
            session.signOut()
        } catch {
            message = (error as? ExpenseDraftError ?? .unexpected).errorDescription
        }
    }
}

#Preview {
    HomeView(user: AuthenticatedUser(.init(id: 1, name: "Paulo Turco", email: "teste@thryve.dev"))!)
        .environment(SessionStore())
}
