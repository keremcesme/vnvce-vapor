
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func acceptFriendRequestHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await acceptFriendRequestV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func acceptFriendRequestV1(_ req: Request) async throws -> VNVCECore.Relationship.V1 {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try req.query.decode(RelationshipParam.V1.self).userID.uuid()
        let relationshipPayload = try req.content.decode(VNVCECore.Relationship.V1.self)
        
        let relationship = try await checkRelationshipV1(userID: userID, targetUserID: targetUserID, req.db)
        
        guard relationshipPayload == relationship else {
            throw Abort(.badRequest)
        }
        
        guard let requestID = relationship.requestID,
              let request = try await FriendRequest.find(requestID, on: req.db)
        else {
            throw Abort(.notFound, reason: relationship.message)
        }
        
        let friendship = Friendship(user1: userID, user2: targetUserID)
        
        try await req.db.transaction{ transaction in
            try await request.delete(force: true, on: transaction)
            try await friendship.create(on: transaction)
        }
        
        let friendshipID = try friendship.requireID()
        
        return .friend(friendshipID: friendshipID)
    }
}
