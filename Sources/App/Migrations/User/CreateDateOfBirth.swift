
import Fluent
import VNVCECore

struct CreateDateOfBirth: AsyncMigration {
    func prepare(on database: Database) async throws {
        let month = try await database.enum(Month.schema).read()
        
        try await database
            .schema(DateOfBirth.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("day", .int8, .required)
            .field("month", month, .required)
            .field("year", .int, .required)
            .create()
        
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(DateOfBirth.schema)
            .delete()
    }
}

