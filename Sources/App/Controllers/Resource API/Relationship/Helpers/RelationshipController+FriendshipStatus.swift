
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func checkFriendshipStatusV1(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database) async throws -> VNVCECore.Relationship.V1 {
        var query = try await Friendship.query(on: on)
            .group(.or) { group in
                group
                    .group(.and) { user in
                        user
                            .filter(\.$user1.$id == userID)
                            .filter(\.$user2.$id == targetUserID)
                    }
                    .group(.and) { targetUser in
                        targetUser
                            .filter(\.$user1.$id == targetUserID)
                            .filter(\.$user2.$id == userID)
                    }
            }
            .all()
        
        guard !query.isEmpty else {
            return .nothing
        }
        
        let first = query.first!
        
        query.removeFirst()
        
        if !query.isEmpty {
            try await query.delete(force: true, on: on)
        }
        
        let id = try first.requireID()
        
        return .friend(friendshipID: id)
    }
}
