
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthController {
    public func verifyOTPAndLoginHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await verifyOTPAndLoginV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func verifyOTPAndLoginV1(_ req: Request) async throws -> LoginResponse.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS,
              let authID = req.headers.authID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let payload = try req.content.decode(VerifyOTPAndLoginPayload.V1.self)
        let query = try req.query.decode(VerifyOTPAndLoginParams.V1.self)
        
        let phoneNumber = query.phoneNumber
        let code = query.code
        let codeVerifier = payload.codeVerifier
        let authCode = payload.authCode
        
        let otpService = req.authService.otp.v1
        let pkceService = req.authService.pkce
        let jwtService = req.authService.jwt.v1
        let redisService = req.authService.redis.v1
        
        guard let authToken = try? req.jwt.verify(authCode, as: JWT.AuthToken.V1.self),
              let auth = await redisService.getAuthWithTTL(authID),
                 !auth.payload.is_verified,
                  authID   == authToken.id(),
                  clientID == authToken.clientID,
                  clientOS.rawValue == authToken.clientOS,
              try await pkceService.verifyCodeChallenge(codeVerifier, auth.payload.code_challenge),
              let user = try await User.find(authToken.userID.uuid(), on: req.db),
              let tokens = try? jwtService.generateTokens(authToken.userID, authID)
        else {
            await redisService.deleteAuth(authID)
            try await Session.query(on: req.db).filter(\.$authID == authID).delete()
            throw Abort(.forbidden)
        }
        
        try await otpService.verifyOTP(phoneNumber: phoneNumber, code: code, on: req)
        
        let refreshTokenID = tokens.refreshToken.tokenID
        
        let accessTokenID = tokens.accessToken.tokenID
        
        await redisService.addRefreshTokenIDandSetVerified(id: authID, result: auth, rtID: refreshTokenID)
        await redisService.addRefreshToken(refreshTokenID)
        await redisService.addAccessToken(accessTokenID)
        
        if let session = try await Session.query(on: req.db)
            .filter(\.$clientID == clientID)
            .filter(\.$clientOS == clientOS)
            .field(\.$authID)
            .first() {
            await redisService.deleteAuthWithRefreshTokens(session.authID)
            try await session.delete(force: true, on: req.db)
        }
        
        let userIDValue = try user.requireID()
        let session = Session(authID: authID, userID: userIDValue, clientID: clientID, clientOS: clientOS)
        
        try await user.$sessions.create(session, on: req.db)
        
        let refreshToken = tokens.refreshToken.token
        let accessToken = tokens.accessToken.token
        
        return .init(userID: userIDValue.uuidString, tokens: .init(accessToken, refreshToken))
    }
}
