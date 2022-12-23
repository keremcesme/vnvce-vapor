//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Fluent
import FluentSQL

struct CreatePhoneNumber: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(PhoneNumber.schema)
            .id()
            .field("phone_number", .string, .required)
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("country_id", .sql(raw: "int"), .references(Country.schema, .id))
            .field("created_at", .datetime, .required)
            .field("modified_at", .datetime, .required)
            .unique(on: "phone_number", name: "phone_numbers_phone_number_ukey")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(PhoneNumber.schema)
            .delete()
    }
}
