
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
            let result = try await authorizeV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func authorizeV1(_ req: Request) async throws -> AuthorizeResponse.V1 {
        guard
            let clientID = req.headers.clientID,
            let clientOS = req.headers.clientOS,
            let os = clientOS.convertClientOS,
            let userID = req.headers.userID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let codeChallenge = try req.query.decode(AuthorizeParams.V1.self).codeChallenge
        let jwt = req.authService.jwt.v1
        let redis = req.authService.redis.v1
        
        let authToken = try jwt.generateAuthToken(userID, clientID, os)
        let authID = authToken.tokenID
        
        await redis.addAuth(authID: authID, challenge: codeChallenge)
        
        let authCode = authToken.token
        
        return .init(authCode, authToken.tokenID)
    }
}

extension AuthorizeResponse.V1: Content {}
