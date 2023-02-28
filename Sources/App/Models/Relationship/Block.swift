
import Fluent
import Vapor
import VNVCECore

final class Block: Model, Content {
    static let schema = "blocks"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "blocked_user_id")
    var blockedUser: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(user: User.IDValue, blockedUser: User.IDValue) {
        self.$user.id = user
        self.$blockedUser.id = blockedUser
    }
}

extension Block {
    func convertRelationship(_ userID: User.IDValue) throws -> VNVCECore.Relationship.V1 {
        if userID == self.$user.$id.value! {
            let id = try self.requireID()
            return .blocked(blockID: id)
        } else {
            return .targetUserBlocked
        }
    }
}
