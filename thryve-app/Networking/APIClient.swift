import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APIClient {
    /// Debug fala com a API rodando na máquina (o simulador enxerga o `localhost` do Mac);
    /// Release, com produção.
    static var baseURL: URL {
        #if DEBUG
        URL(string: "http://localhost:3000")!
        #else
        URL(string: "https://apithryve.pauloturcko.dev")!
        #endif
    }

    static func make(tokenStore: TokenStore) -> Client {
        Client(
            serverURL: baseURL,
            // A API devolve datas com milissegundos (`2026-11-22T06:27:06.990Z`), que o ISO 8601 padrão não lê.
            configuration: Configuration(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware(tokenStore: tokenStore)]
        )
    }
}
