
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthController {
    public func generateTokensHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion)
        else {
            throw Abort(.badRequest, reason: "Missing version header.")
        }
        
        switch version {
        case .v1:
            let result = try await generateTokensV1(req)
            return .init(result)
        default:
            throw Abort(.badRequest)
        }
    }
    
    private func generateTokensV1(_ req: Request) async throws -> TokensResponse.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS,
              let authID = req.headers.authID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let p = try req.content.decode(GenerateTokensPayload.V1.self)
        let authCode = p.authCode
        let codeVerifier = p.codeVerifier
        
        let jwt = req.authService.jwt.v1
        let redis = req.authService.redis.v1
        let pkce = req.authService.pkce
        
        guard let authToken = try? req.jwt.verify(authCode, as: JWT.AuthToken.V1.self),
              let auth = await redis.getAuthWithTTL(authID),
                 !auth.payload.is_verified,
                  authID   == authToken.id(),
                  clientID == authToken.clientID,
                  clientOS.rawValue == authToken.clientOS,
              try await pkce.verifyCodeChallenge(codeVerifier, auth.payload.code_challenge),
              let user = try await User.find(authToken.userID.uuid(), on: req.db),
              let tokens = try? jwt.generateTokens(authToken.userID, authID)
        else {
            await redis.deleteAuth(authID)
            try await Session.query(on: req.db).filter(\.$authID == authID).delete()
            throw Abort(.forbidden)
        }
        
        let refreshToken = tokens.refreshToken.token
        let refreshTokenID = tokens.refreshToken.tokenID
        let accessToken = tokens.accessToken.token
        let accessTokenID = tokens.accessToken.tokenID
        
        await redis.addRefreshTokenIDandSetVerified(id: authID, result: auth, rtID: refreshTokenID)
        await redis.addRefreshToken(refreshTokenID)
        await redis.addAccessToken(accessTokenID)
        
        let userIDValue = try user.requireID()
        let session = Session(authID: authID, userID: userIDValue, clientID: clientID, clientOS: clientOS)
        
        try await user.$sessions.create(session, on: req.db)
        
        return .init(accessToken, refreshToken)
    }
}
