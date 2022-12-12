
import Vapor
import VNVCECore

extension AuthController {
    public func authorizeHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
//            let result = try await authorizeV1(req)
//            return .init(result)
            throw Abort(.notFound)
        default:
            throw Abort(.notFound)
        }
    }
    
//    private func authorizeV1(_ req: Request) async throws -> AuthorizeResponse.V1 {
//        let p = try req.content.decode(AuthorizePayload.V1.self)
//        let jwtService = req.authService.jwt.v1
//        let redis = req.authService.redis.v1
//        let code = req.authService.code
//
//        let authCode = try jwtService.generateAuthCode(p.userID)
//
//        try await redis.addAuthCodeToBucket(
//            p.userID,
//            p.codeChallenge,
//            p.clientID,
//            authCode.jwtID)
//
//        let jwt = authCode.value
//
//        return .init(jwt)
//    }
}

extension AuthorizeResponse.V1: Content {}
