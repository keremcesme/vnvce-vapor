
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func reAuthorizeHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await reAuthorizeV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func reAuthorizeV1(_ req: Request) async throws -> AuthorizeResponse.V1 {
        guard let refreshToken = req.headers.refreshToken,
              let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS,
              let authID = req.headers.authID,
              let userID = req.headers.userID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let p = try req.content.decode(ReAuthorizePayload.V1.self)
        let oldAuthCode = p.authCode
        let oldCodeverifier = p.codeVerifier
        
        let newCodeChallenge = try req.query.decode(AuthorizeParams.V1.self).codeChallenge
        
        let jwt = req.authService.jwt.v1
        let redis = req.authService.redis.v1
        let pkce = req.authService.pkce
        
        guard let rtJWT = jwt.validate(refreshToken, as: JWT.RefreshToken.V1.self) else {
            throw Abort(.forbidden)
        }
        
        let rtID = rtJWT.payload.id()
        
        guard rtJWT.payload.authID == authID,
              rtJWT.payload.userID == userID
        else {
            await redis.revokeRefreshToken(rtID)
            throw Abort(.forbidden)
        }
        
        if rtJWT.isVerified {
            guard let rt = await redis.getRefreshTokenWithTTL(rtID),
                      rt.payload.is_active else {
                throw Abort(.forbidden)
            }
            
            if rt.payload.inactivity_exp > Int(Date().timeIntervalSince1970) {
                await redis.revokeRefreshToken(rtID)
                throw Abort(.forbidden)
            }
        }
        
        guard let authToken = try? req.jwt.verify(oldAuthCode, as: JWT.AuthToken.V1.self),
              let auth = await redis.getAuth(authID),
              auth.is_verified,
              auth.refresh_token_ids.contains(rtID),
              authID   == authToken.id(),
              userID   == authToken.userID,
              clientID == authToken.clientID,
              clientOS.rawValue == authToken.clientOS,
              try await pkce.verifyCodeChallenge(oldCodeverifier, auth.code_challenge)
        else {
            await redis.deleteAuth(authID)
            try await Session.query(on: req.db).filter(\.$authID == authID).delete()
            throw Abort(.forbidden)
        }
        
        let newAuthToken = try jwt.generateAuthToken(userID, clientID, clientOS)
        let newAuthID = newAuthToken.tokenID
        
        await redis.deleteAuthWithRefreshTokens(authID, auth: auth)
        
        try await Session.query(on: req.db).filter(\.$authID == authID).delete()
        
        await redis.addAuth(authID: newAuthID, challenge: newCodeChallenge)
        
        let authCode = newAuthToken.token
        
        return .init(authCode, newAuthToken.tokenID)
    }
}
