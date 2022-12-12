
import Vapor
import Fluent
import VNVCECore

struct TokenAuthMiddleware: AsyncMiddleware {
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
        guard
            let accessToken = request.headers.bearerAuthorization?.token,
            let headerVersion = request.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion)
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        switch version {
        case .v1:
            try await accessTokenAuthorizationV1(accessToken, to: request)
        default:
            throw Abort(.badRequest, reason: "Version `\(headerVersion)` is not available for this request.")
        }
        
        return try await next.respond(to: request)
    }
    
    private func accessTokenAuthorizationV1(_ accessToken: String, to request: Request) async throws {
        let redis = request.authService.redis.v1
        let jwt = try request.jwt.verify(accessToken, as: JWT.AccessToken.V1.self)
        let userID = UUID(uuidString: jwt.userID)
        let accessTokenID = jwt.id()
        let refreshTokenID = jwt.refreshTokenID
        let accessTokenResult = try await redis.getAccessToken(accessTokenID)
        
        if case let .success(accessToken) = accessTokenResult {
            if accessToken.payload.is_active {
                let refreshTokenResult = try await redis.getRefreshToken(refreshTokenID)
                if case let .success(refreshToken) = refreshTokenResult, refreshToken.payload.is_active {
                    /// User not found.
                    guard let user = try await User.find(userID, on: request.db) else {
                        throw Abort(.notFound, reason: "User not found.")
                    }
                    /// MARK: User Verified. (`Access` & `Refresh` Tokens is valid.)
                    request.auth.login(user)
                } else {
                    /// The `Access Token` will be marked `is_active` key `false`
                    /// because the `Refresh Token` is not found
                    /// or RT's `is_active` key is marked `false`.
                    try await redis.revokeAccessToken(accessTokenID, accessToken)
                }
            } else {
                /// The `Access Token` will be deleted because
                /// previously the `is_active` key was marked `false`.
                try await redis.deleteAccessToken(accessTokenID)
            }
        }
    }
}
