
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthController {
    public func tokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion)
        else {
            throw Abort(.badRequest, reason: "Missing version header.")
        }
        
        switch version {
        case .v1:
            let result = try await tokenV1(req)
            return .init(result)
        default:
            throw Abort(.badRequest)
        }
    }
    
    private func tokenV1(_ req: Request) async throws -> VNVCECore.TokenResponse.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS,
              let authID = req.headers.authID,
              let userID = req.headers.userID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let p = try req.content.decode(VNVCECore.TokenPayload.V1.self)
        let authCode = p.authCode
        let codeVerifier = p.codeVerifier
        
        let jwt = req.authService.jwt.v1
        let redis = req.authService.redis.v1
        let code = req.authService.code
        
        guard let authToken = try? req.jwt.verify(authCode, as: JWT.AuthToken.V1.self),
              let auth = try await redis.getAuthWithTTL(authID),
                 !auth.payload.is_verified,
                  authID   == authToken.id(),
                  userID   == authToken.userID,
                  userID   == auth.payload.user_id,
                  userID   == authToken.userID,
                  userID   == auth.payload.user_id,
                  clientID == authToken.clientID,
                  clientID == auth.payload.client_id,
                  clientOS == authToken.clientOS,
                  clientOS == auth.payload.client_os,
              try await code.verifyCodeChallenge(codeVerifier, auth.payload.code_challenge)
        else {
            throw Abort(.forbidden)
        }
        
        try await redis.setAuthVerified(authID)
        
        let tokens = try jwt.generateTokens(userID, authID)
        let refreshToken = tokens.refreshToken.token
        let refreshTokenID = tokens.refreshToken.tokenID
        let accessToken = tokens.accessToken.token
        let accessTokenID = tokens.accessToken.tokenID
        
        try await redis.addAccessToken(accessTokenID)
        try await redis.addRefreshToken(refreshTokenID)
        try await redis.addRefreshTokenIDtoAuth(authID, refreshTokenID)
        try await redis.setLoggedIn(userID, authID)
        
        
        
        return .init(accessToken, refreshToken)
    }
}

extension VNVCECore.TokenResponse.V1: Content {}
