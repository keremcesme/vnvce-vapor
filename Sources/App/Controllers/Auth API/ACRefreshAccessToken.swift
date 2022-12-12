
import Vapor
import VNVCECore

extension AuthController {
    public func refreshAccessTokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            
            let headerVersion = req.headers.acceptVersion,
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
        // HEADERS:
        guard let refreshToken = req.headers.refreshToken else {
            throw Abort(.badRequest, reason: "Missing Refresh Token.")
        }
        guard let expiredAccessToken = req.headers.bearerAuthorization?.token else {
            throw Abort(.badRequest, reason: "Missing expired Access Token.")
        }
        
        // SERVICES:
        let redis = req.authService.redis.v1
        let jwt = req.authService.jwt.v1
        
        // Refresh Token JWT
        let refreshTokenValidationResult = jwt.validate(refreshToken, as: JWT.RefreshToken.V1.self)
        guard case let .success(refreshTokenValidationResult) = refreshTokenValidationResult else {
            throw Abort(.badRequest, reason: "The Refresh Token must be a JWT.")
        }
            
        // Expired Access Token JWT
        let accessTokenValidationResult = jwt.validate(expiredAccessToken, as: JWT.AccessToken.V1.self)
        guard case let .success(accessTokenValidationResult) = accessTokenValidationResult else {
            throw Abort(.badRequest, reason: "The expired Access Token must be a JWT.")
        }
        
        // JWT Payloads
        let refreshTokenJWTPayload = refreshTokenValidationResult.payload
        let accessTokenJWTPayload = accessTokenValidationResult.payload
        
        // Token ID's
        let accessTokenID = accessTokenJWTPayload.id()
        let refreshTokenID = refreshTokenJWTPayload.id()
        
        guard refreshTokenID == accessTokenJWTPayload.refreshTokenID else {
            // Access Token's `Refresh Token ID` not match.
            throw Abort(.badRequest)
        }
        
        guard refreshTokenJWTPayload.userID == accessTokenJWTPayload.userID else {
            // Expired Access Token and Refresh Token `userID` not match.
            throw Abort(.badRequest)
        }
        
        guard refreshTokenValidationResult.isVerified else {
            // Absolute TTL expired
            throw Abort(.unauthorized)
        }
        
        // Get Refresh Token from Redis
        let refreshTokenResult = try await redis.getRefreshToken(refreshTokenID)
        guard case let .success(refreshToken) = refreshTokenResult else {
            // Refresh Token not found on Redis
            throw Abort(.unauthorized)
        }
        
        // Check Refresh Token revoke status on Redis
        guard refreshToken.payload.is_active else {
            // Refresh Token is Revoked
            throw Abort(.badRequest)
        }
        
        // Check Refresh Token Inactivity
        let currentDate = Int(Date().timeIntervalSince1970)
        guard refreshToken.payload.inactivity_exp > currentDate else {
            // Inactivity TTL expired
            throw Abort(.unauthorized)
        }
        
        // Revoke old access token
        let accessTokenResult = try await redis.getAccessToken(accessTokenID)
        if case let .success(accessToken) = accessTokenResult, accessToken.payload.is_active {
            try await redis.revokeAccessToken(accessTokenID, accessToken)
        }
        
        /// ✅ Refresh Token ID matched
        /// ✅ User ID matched
        /// ✅ Absolute time not expired
        /// ✅ Refresh Token available on Redis
        /// ✅ Refresh Token not revoked
        /// ✅ Inactivity time not expired
        /// ✅ If its possible revoke old access token
        
        let newAccessToken = try jwt.generateAccessToken(refreshTokenJWTPayload.userID, refreshTokenID)
        try await redis.addAccessToken(newAccessToken.tokenID)
        try await redis.updateRefreshTokenInactivity(refreshTokenID, refreshToken)
        
        
        return .init("Access Token: \(newAccessToken.token)")
    }
}
