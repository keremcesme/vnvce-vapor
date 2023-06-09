
import Fluent
import VNVCECore

struct CreateMediaType: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(MediaType.schema)
            .case("image")
            .case("movie")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(MediaType.schema).delete()
    }
}
