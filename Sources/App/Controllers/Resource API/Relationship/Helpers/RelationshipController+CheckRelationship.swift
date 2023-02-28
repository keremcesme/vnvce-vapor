
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func checkRelationshipV1(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database) async throws -> VNVCECore.Relationship.V1 {
        
        if let blockStatus = try await checkBlockStatusV1(
            userID: userID,
            targetUserID: targetUserID,
            on) {
            return blockStatus
        }
        
        if let requestStatus = try await checkFriendRequestStatusV1(
            userID: userID,
            targetUserID: targetUserID, on) {
            return requestStatus
        }
        
        let friendshipStatus = try await checkFriendshipStatusV1(
            userID: userID,
            targetUserID: targetUserID,
            on)
        
        return friendshipStatus
    }
    
}
