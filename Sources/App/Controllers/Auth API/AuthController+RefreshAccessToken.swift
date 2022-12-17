
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func refreshAccessTokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            return try await refreshAccessTokenV1(req)
        default:
            throw Abort(.notFound, reason: "Version `\(headerVersion)` is not available for this request.")
        }
    }
    
    private func refreshAccessTokenV1(_ req: Request) async throws -> AnyAsyncResponse {
        guard let refreshToken = req.headers.bearerAuthorization?.token,
              let accessToken = req.headers.accessToken,
              let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let redis = req.authService.redis.v1
        let jwtService = req.authService.jwt.v1
        
        guard let jwt = try? req.jwt.verify(refreshToken, as: JWT.RefreshToken.V1.self) else {
            throw Abort(.unauthorized)
        }
        
        let userID = jwt.userID
        let rtID = jwt.id()
        let authID = jwt.authID
        
        guard let rt = await redis.getRefreshTokenWithTTL(rtID) else {
            throw Abort(.unauthorized)
        }
        
        guard rt.payload.is_active else {
            await redis.revokeAllRefreshTokens(authID)
            throw Abort(.forbidden)
        }
        
        guard rt.payload.inactivity_exp > Int(Date().timeIntervalSince1970) else {
            throw Abort(.unauthorized)
        }
        
        guard let auth = await redis.getAuth(authID),
                  auth.client_id == clientID,
                  auth.client_os == clientOS,
                  auth.user_id == userID,
                  auth.refresh_token_ids.contains(rtID),
                  auth.is_verified
        else {
            await redis.revokeRefreshToken(rtID, rt)
            throw Abort(.forbidden)
        }
        
        guard let authTokenIDs = await redis.getUser(userID)?.auth_token_ids,
                  authTokenIDs.contains(authID)
        else {
            await redis.deleteRefreshToken(rtID)
            await redis.deleteAllRefreshTokens(auth)
            await redis.deleteAllAuths(userID)
            await redis.deleteAuth(authID)
            
            throw Abort(.forbidden)
        }
        
        guard try await User.find(userID.uuid(), on: req.db)?.requireID() != nil else {
            await redis.deleteRefreshToken(rtID)
            await redis.deleteAllRefreshTokens(auth)
            await redis.deleteAuth(authID)
            await redis.deleteAllAuths(userID)
            await redis.deleteUser(userID)
            throw Abort(.forbidden)
        }
        
        if let atID = jwtService.validate(accessToken, as: JWT.AccessToken.V1.self)?.payload.id() {
            await redis.revokeAccessToken(atID)
        }
        
        let token = try jwtService.generateAccessToken(userID, rtID)
        let accessTokenID = token.tokenID

        try await redis.addAccessToken(accessTokenID)
        try await redis.updateRefreshTokenInactivity(rtID, rt)

        return .init("Access Token: \(token.token)")
    }
    
}
