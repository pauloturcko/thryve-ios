import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum APIClient {
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
            configuration: Configuration(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: URLSessionTransport(),
            middlewares: [AuthMiddleware(tokenStore: tokenStore)]
        )
    }
}
