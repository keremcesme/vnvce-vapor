//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Fluent

struct CreatePhoneNumber: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(PhoneNumber.schema)
            .id()
            .field("phone_number", .string, .required)
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("modified_at", .datetime, .required)
            .unique(on: "phone_number", name: "uk_phone_number")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(PhoneNumber.schema)
            .delete()
    }
}
