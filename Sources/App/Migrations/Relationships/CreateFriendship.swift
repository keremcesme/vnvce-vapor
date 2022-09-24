//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Fluent

struct CreateFriendship: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(Friendship.schema)
            .id()
            .field("user_1_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("user_2_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(Friendship.schema)
            .delete()
    }
}
