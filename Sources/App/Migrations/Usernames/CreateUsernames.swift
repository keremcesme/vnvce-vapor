//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent

struct CreateUsername: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(Username.schema)
            .id()
            .field("username", .string, .required)
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("modified_at", .datetime, .required)
            .unique(on: "username", name: "usernames_username_ukey")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(Username.schema)
            .delete()
    }
}
