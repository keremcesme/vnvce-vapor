//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(User.schema)
            .id()
            .field("display_name", .string)
            .field("biography", .string)
            .field("profile_picture_url", .string)
            .field("created_at", .datetime, .required)
            .field("modified_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(User.schema)
            .delete()
    }
    
}
