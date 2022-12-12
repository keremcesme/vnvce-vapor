
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthController {
    public func tokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
//            let result = try await tokenV1(req)
//            return .init(result)
            throw Abort(.notFound)
        default:
            throw Abort(.notFound)
        }
    }
    
//    private func tokenV1(_ req: Request) async throws -> VNVCECore.TokenResponse.V1 {
//        let p = try req.content.decode(VNVCECore.TokenPayload.V1.self)
//        let jwtService = req.authService.jwt.v1
//        let redis = req.authService.redis.v1
//        let code = req.authService.code
//
//        let jwtID = try req.jwt.verify(p.authCode, as: AuthCodePayload.V1.self).jti.value
//
//        var result = try await redis.getAuthCodeFromBucket(jwtID)
//
//        switch result {
//        case let .success(payload):
//            let verifyResult = try await code.verifyCodeChallenge(verifier: p.codeVerifier, challenge: payload.codeChallenge)
//
//            guard p.userID == payload.userID else {
//                print("user id not match")
//                throw Abort(.notFound)
//            }
//
//            guard p.clientID == payload.clientID else {
//                print("client id not match")
//                throw Abort(.notFound)
//            }
//
//            guard verifyResult else {
//                print("code challenge not verified")
//                throw Abort(.notFound)
//            }
//
//            let tokens = try jwtService.generateTokens(p.userID)
//            try await redis.addTokenToBucket(tokenID: tokens.refreshToken.jwtID, to: .refreshToken(jwtID))
//            try await redis.addTokenToBucket(tokenID: tokens.accessToken.jwtID, to: .accessToken(tokens.refreshToken.jwtID))
//
////            var payload = payload
////            let ttl = try await redis.getAuthCodeTTLFromBucket(p.authCode)
////            payload.refreshTokenID = tokens.refreshToken.jwtID
//
////            try await redis.updateAuthCodeFromBucket(p.authCode, payload, ttl)
//
//            return .init(tokens.accessToken.value, tokens.refreshToken.value)
//        case .notFound:
//            throw Abort(.notFound)
//        }
//
//    }
}

extension VNVCECore.TokenResponse.V1: Content {}
