
import Vapor
import Fluent
import VNVCECore

final class Membership: Model, Content {
    static let schema = "memberships"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "is_active")
    var isActive: Bool
    
    @Enum(key: "status")
    var status: MembershipStatus
    
    @OptionalEnum(key: "provider")
    var provider: PaymentProvider?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$membership)
    var transactions: [AppStoreTransaction]
    
    init(){}
    
    init(userID: User.IDValue, status: MembershipStatus = .none, provider: PaymentProvider? = nil) {
        self.$user.id = userID
        self.status = status
        self.isActive = status.isActive
        self.provider = provider
    }
    
}
