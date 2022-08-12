//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent

struct CreateReservedUsername: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(ReservedUsername.schema)
            .id()
            .field("username", .string, .required)
            .field("client_id", .uuid, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(ReservedUsername.schema)
            .delete()
    }
    
}
