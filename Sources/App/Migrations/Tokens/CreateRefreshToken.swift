//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent

struct CreateRefreshToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(RefreshToken.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("token", .string, .required)
            .field("client_id", .uuid, .required)
            .field("expires_at", .datetime, .required)
            .field("created_at", .datetime, .required)
            .unique(on: "token", name: "uk_refresh_token")
            .unique(on: "client_id", name: "uk_refresh_token_client_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(RefreshToken.schema)
            .delete()
    }
}
