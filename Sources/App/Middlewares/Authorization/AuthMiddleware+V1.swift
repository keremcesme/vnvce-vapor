
import Vapor
import Fluent
import JWT

extension AuthMiddleware {
    public func authorizationV1(_ req: Request) async throws {
        guard let accessToken = req.headers.bearerAuthorization?.token,
              let authID = req.headers.authID,
              let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let redis = req.authService.redis.v1
        let jwtService = req.authService.jwt.v1
        
        guard let decodedJWT = jwtService.validate(accessToken, as: JWT.AccessToken.V1.self) else {
            throw Abort(.forbidden)
        }
        
        let jwtPayload = decodedJWT.payload
        
        let userID = jwtPayload.userID
        let atID = jwtPayload.id()
        let rtID = jwtPayload.refreshTokenID
        
        guard decodedJWT.isVerified,
              let at = try await redis.getAccessTokenWithTTL(atID)
        else {
            throw await verifyAuth()
        }
        
        guard at.payload.is_active else {
            throw Abort(.forbidden)
        }
        
        guard let rt = await redis.getRefreshTokenWithTTL(rtID) else {
            throw await verifyAuth()
        }
        
        guard rt.payload.is_active else {
            await redis.revokeAccessToken(atID, at)
            throw Abort(.forbidden)
        }
        
        guard rt.payload.inactivity_exp > Int(Date().timeIntervalSince1970) else {
            await redis.revokeAccessToken(atID, at)
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
            await redis.revokeAccessToken(atID, at)
            await redis.revokeRefreshToken(rtID, rt)
            throw Abort(.forbidden)
        }
        
        guard let user = try await User.find(userID.uuid(), on: req.db) else {
            await resetRedis()
            throw Abort(.forbidden)
        }
        
        try await user.$sessions.load(on: req.db)
        let sessions = user.sessions
        
        guard let inx = sessions.firstIndex(where: { $0.authID == authID} ),
                  sessions[inx].clientID == clientID,
                  sessions[inx].clientOS == clientOS
        else {
            await resetRedis()
            throw Abort(.forbidden)
        }
        
        func resetRedis() async {
            await redis.revokeAccessToken(atID, at)
            await redis.deleteRefreshToken(rtID)
            await redis.deleteAuthWithRefreshTokens(authID, auth: auth)
        }

        req.auth.login(user)
    }
}
