
import Fluent
import VNVCECore

struct CreateMembership: AsyncMigration {
    func prepare(on database: Database) async throws {
        let status = try await database.enum(MembershipStatus.schema).read()
        let provider = try await database.enum(PaymentProvider.schema).read()
        
        try await database.schema(Membership.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("is_active", .bool, .required)
            .field("status", status, .required)
            .field("provider", provider)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", name: "memberships_user_id_ukey")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Membership.schema).delete()
    }
}
