
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func logoutHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await logoutV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func logoutV1(_ req: Request) async throws -> HTTPStatus {
        guard let userID = req.headers.userID,
              let authID = req.headers.authID
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let redisService = req.authService.redis.v1
        
        try await Session.query(on: req.db)
            .filter(\.$user.$id == userID.convertUUID)
            .filter(\.$authID == authID)
            .delete(force: true)
        
        try await NotificationToken.query(on: req.db)
            .filter(\.$user.$id == userID.convertUUID)
            .delete(force: true)
        
        await redisService.deleteAuthWithRefreshTokens(authID)
        
        return .ok
    }
    
}
