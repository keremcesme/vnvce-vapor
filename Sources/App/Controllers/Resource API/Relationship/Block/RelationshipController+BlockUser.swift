
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func blockUserHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await blockUserV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func blockUserV1(_ req: Request) async throws -> VNVCECore.Relationship.V1 {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try req.query.decode(RelationshipParam.V1.self).userID.uuid()
        
        let relationship = try await checkRelationshipV1(userID: userID, targetUserID: targetUserID, req.db)
        
        let blockID: Block.IDValue = try await req.db.transaction {
            switch relationship {
            case let .friend(friendshipID):
                try await Friendship.query(on: $0).filter(\.$id == friendshipID).delete(force: true)
            case let .friendRequestSubmitted(requestID):
                try await FriendRequest.query(on: $0).filter(\.$id == requestID).delete(force: true)
            case let .friendRequestReceived(requestID):
                try await FriendRequest.query(on: $0).filter(\.$id == requestID).delete(force: true)
            case .blocked:
                throw Abort(.badRequest, reason: "User already blocked.")
            default: break
            }
            
            let block = Block(user: userID, blockedUser: targetUserID)
            
            try await block.create(on: $0)
            
            return try block.requireID()
        }
        
        return .blocked(blockID: blockID)
    }
}
