import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Coloca o JWT salvo em toda requisição, menos no login, que é quem gera o token.
struct AuthMiddleware: ClientMiddleware {
    let tokenStore: TokenStore

    private static let publicOperations: Set<String> = [Operations.PostUsersLogin.id]

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @concurrent @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if !Self.publicOperations.contains(operationID), let token = tokenStore.read() {
            request.headerFields[.authorization] = "Bearer \(token)"
        }
        return try await next(request, body, baseURL)
    }
}
