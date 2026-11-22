import Foundation
import Observation
import OpenAPIRuntime

struct AuthenticatedUser: Equatable, Sendable {
    let id: Int
    let name: String
    let email: String

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    init?(_ response: Components.Schemas.UserResponse?) {
        guard let response, let id = response.id, let name = response.name, let email = response.email else {
            return nil
        }
        self.id = id
        self.name = name
        self.email = email
    }
}

enum LoginError: LocalizedError {
    case invalidCredentials
    case invalidInput
    case connection
    case unexpected

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "E-mail ou senha incorretos."
        case .invalidInput: "Confira o e-mail e a senha."
        case .connection: "Não foi possível conectar. Verifique sua internet."
        case .unexpected: "Algo deu errado. Tente de novo."
        }
    }
}

/// Estado de autenticação do app. Ainda não há refresh token na API: quando o JWT (1h) vence,
/// a próxima chamada responde 401 e a sessão volta para o login.
@MainActor
@Observable
final class SessionStore {
    enum State: Equatable {
        case restoring
        case signedOut
        case signedIn(AuthenticatedUser)
        /// Havia token salvo, mas a API não respondeu: não dá para saber se ele ainda vale.
        case restoreFailed
    }

    private(set) var state: State = .restoring

    private let tokenStore: TokenStore
    private let client: Client

    init(tokenStore: TokenStore = TokenStore()) {
        self.tokenStore = tokenStore
        client = APIClient.make(tokenStore: tokenStore)
    }

    func restore() async {
        guard tokenStore.read() != nil else {
            state = .signedOut
            return
        }
        state = .restoring
        do {
            switch try await client.getUsersMe() {
            case let .ok(response):
                guard let user = AuthenticatedUser(try response.body.json.user) else {
                    signOut()
                    return
                }
                state = .signedIn(user)
            case .unauthorized:
                signOut()
            case .undocumented:
                state = .restoreFailed
            }
        } catch {
            state = .restoreFailed
        }
    }

    func signIn(email: String, password: String) async throws {
        let output: Operations.PostUsersLogin.Output
        do {
            output = try await client.postUsersLogin(body: .json(.init(email: email, password: password)))
        } catch let error as ClientError where error.underlyingError is URLError {
            throw LoginError.connection
        } catch {
            throw LoginError.unexpected
        }

        switch output {
        case let .ok(response):
            guard let body = try? response.body.json,
                  let token = body.token,
                  let user = AuthenticatedUser(body.user)
            else { throw LoginError.unexpected }
            tokenStore.save(token)
            state = .signedIn(user)
        case .unauthorized:
            throw LoginError.invalidCredentials
        case .badRequest:
            throw LoginError.invalidInput
        case .undocumented:
            throw LoginError.unexpected
        }
    }

    func signOut() {
        tokenStore.delete()
        state = .signedOut
    }
}
