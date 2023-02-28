
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func removeFriendHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await removeFriendV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func removeFriendV1(_ req: Request) async throws -> VNVCECore.Relationship.V1 {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try req.query.decode(RelationshipParam.V1.self).userID.uuid()
        let relationshipPayload = try req.content.decode(VNVCECore.Relationship.V1.self)
        
        let relationship = try await checkRelationshipV1(userID: userID, targetUserID: targetUserID, req.db)
        
        guard relationshipPayload == relationship else {
            throw Abort(.badRequest)
        }
        
        guard let friendshipID = relationship.friendshipID,
              let friendship = try await Friendship.find(friendshipID, on: req.db)
        else {
            throw Abort(.notFound, reason: relationship.message)
        }
        
        try await friendship.delete(force: true, on: req.db)
        
        return .nothing
    }
}
