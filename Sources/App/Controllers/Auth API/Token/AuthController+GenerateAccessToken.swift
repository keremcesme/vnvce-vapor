
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func generateAccessTokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await generateAccessTokenV1(req)
            return .init(result)
        default:
            throw Abort(.notFound, reason: "Version `\(headerVersion)` is not available for this request.")
        }
    }
    
    private func generateAccessTokenV1(_ req: Request) async throws -> String {
        guard let refreshToken = req.headers.bearerAuthorization?.token,
              let accessToken = req.headers.accessToken,
              let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }

        let redis = req.authService.redis.v1
        let jwt = req.authService.jwt.v1
        
        guard let decodedJWT = jwt.validate(refreshToken, as: JWT.RefreshToken.V1.self) else {
            throw Abort(.forbidden)
        }

        let jwtPayload = decodedJWT.payload
        let userID = jwtPayload.userID
        let rtID = jwtPayload.id()
        let authID = jwtPayload.authID
        
        guard let decodedATJWT = jwt.validate(accessToken, as: JWT.AccessToken.V1.self),
                  decodedATJWT.payload.userID == userID,
                  decodedATJWT.payload.refreshTokenID == rtID
        else {
            await redis.revokeRefreshToken(rtID)
            throw Abort(.forbidden)
        }
        
        guard decodedJWT.isVerified, let rt = await redis.getRefreshTokenWithTTL(rtID) else {
            throw await verifyAuth()
        }

        guard rt.payload.is_active else {
            await redis.revokeAllRefreshTokens(authID)
            throw Abort(.forbidden)
        }

        guard rt.payload.inactivity_exp > Int(Date().timeIntervalSince1970) else {
            throw await verifyAuth()
        }
        
        func verifyAuth() async -> Abort {
            if await redis.verifyAuth(authID: authID, rtID: rtID) {
                return Abort(.unauthorized)
            } else {
                return Abort(.forbidden)
            }
        }

        guard let auth = await redis.getAuth(authID),
                  auth.refresh_token_ids.contains(rtID),
                  auth.is_verified
        else {
            await redis.revokeRefreshToken(rtID, rt)
            throw Abort(.forbidden)
        }

        guard let user = try await User.find(userID.uuid(), on: req.db) else {
            await redis.deleteAuthWithRefreshTokens(authID, auth: auth)
            throw Abort(.forbidden)
        }
        
        try await user.$sessions.load(on: req.db)
        let sessions = user.sessions
        
        guard let inx = sessions.firstIndex(where: { $0.authID == authID} ) else {
            await redis.deleteAuthWithRefreshTokens(authID, auth: auth)
            throw Abort(.forbidden)
        }
        
        guard sessions[inx].clientID == clientID,
              sessions[inx].clientOS == clientOS
        else {
            await redis.revokeAllRefreshTokens(auth)
            throw Abort(.forbidden)
        }

        if let atID = jwt.validate(accessToken, as: JWT.AccessToken.V1.self)?.payload.id() {
            await redis.revokeAccessToken(atID)
        }

        let token = try jwt.generateAccessToken(userID, rtID)
        let accessTokenID = token.tokenID

        await redis.addAccessToken(accessTokenID)
        await redis.updateRefreshTokenInactivity(rtID, rt)

        return token.token
    }
}
