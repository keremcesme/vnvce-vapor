
import Fluent
import VNVCECore

struct CreateMomentAudience: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(MomentAudience.schema)
            .case("friendsOnly")
            .case("friendsOfFriends")
            .case("nearby")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(MomentAudience.schema).delete()
    }
}
