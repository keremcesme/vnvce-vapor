
import Fluent
import FluentPostgresDriver
import FluentPostGIS
import VNVCECore

struct CreateMoment: AsyncMigration {
    func prepare(on database: Database) async throws {
        let mediaType = try await database.enum(MediaType.schema).read()
        let audience = try await database.enum(MomentAudience.schema).read()
        
        try await database.schema(Moment.schema)
            .id()
            .field("owner_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("message", .string)
            .field("audience", audience, .required)
            .field("location", .geometricPoint2D)
            .field("created_at", .datetime, .required)
            .create()
        
        try await database.schema(MomentMediaDetail.schema)
            .id()
            .field("moment_id", .uuid, .required, .references(Moment.schema, .id, onDelete: .cascade))
            .field("media_type", mediaType, .required)
            .field("url", .string, .required)
            .field("thumbnail_url", .string)
            .field("sensitive_content", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(MomentMediaDetail.schema).delete()
        try await database.schema(Moment.schema).delete()
    }
    
}
