//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Fluent

struct CreateFriendRequest: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(FriendRequest.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("submitted_user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(FriendRequest.schema)
            .delete()
    }
}
