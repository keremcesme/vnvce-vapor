
import Fluent
import VNVCECore

struct CreateSession: AsyncMigration {
    func prepare(on database: Database) async throws {
        let clientOS = try await database.enum(ClientOS.schema).read()
        
        try await database
            .schema(Session.schema)
            .id()
            .field("auth_id", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("client_id", .string, .required)
            .field("client_os", clientOS, .required)
            .field("created_at", .datetime, .required)
            .unique(on: "auth_id", name: "sessions_auth_id_ukey")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Session.schema).delete()
    }
}
