
import Vapor
import Fluent
import VNVCECore

extension NotificationController {
    public func registerTokenHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.badRequest)
        }
        
        switch version {
        case .v1:
            let result = try await registerTokenV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func registerTokenV1(_ req: Request) async throws -> HTTPStatus {
        guard let clientOS = req.headers.clientOS?.convertClientOS else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        let token = try req.query.decode(NotificationTokenParam.V1.self).token
        
        switch clientOS {
        case .ios:
            try await NotificationToken.query(on: req.db)
                .filter(\.$user.$id == userID)
                .delete()
            
            try await user.$notificationToken.create(
                .init(
                    token: token,
                    userID: userID,
                    clientOS: clientOS),
                on: req.db)
            
            return .ok
        case .android:
            throw Abort(.notFound)
        }
    }
}
