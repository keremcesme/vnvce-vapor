
import Fluent
import Vapor
import VNVCECore

final class FriendRequest: Model, Content {
    static let schema = "friend_requests"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "submitted_user_id")
    var submittedUser: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        user: User.IDValue,
        submittedUser: User.IDValue
    ) {
        self.$user.id = user
        self.$submittedUser.id = submittedUser
    }
}

extension FriendRequest {
    func convertRelationship(_ userID: User.IDValue) throws -> VNVCECore.Relationship.V1 {
        let id = try self.requireID()
        if userID == self.$user.$id.value! {
            return .friendRequestSubmitted(requestID: id)
        } else {
            return .friendRequestReceived(requestID: id)
        }
    }
}
