import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func checkFriendRequestStatusV1(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database) async throws -> VNVCECore.Relationship.V1? {
        var query = try await FriendRequest.query(on: on)
            .group(.or) { group in
                group
                    .group(.and) { user in
                        user
                            .filter(\.$user.$id == userID)
                            .filter(\.$submittedUser.$id == targetUserID)
                    }
                    .group(.and) { targetUser in
                        targetUser
                            .filter(\.$user.$id == targetUserID)
                            .filter(\.$submittedUser.$id == userID)
                    }
            }
            .all()
        
        guard !query.isEmpty else {
            return nil
        }
        
        let first = query.first!
        
        query.removeFirst()
        
        if !query.isEmpty {
            try await query.delete(force: true, on: on)
        }
        
        return try first.convertRelationship(userID)
    }
}
