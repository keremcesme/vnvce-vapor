//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent

struct CreateProfilePicture: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        let alignment = try await database.enum(ProfilePictureAlignmentType.schema).read()
        
        try await database
            .schema(ProfilePicture.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("alignment", alignment, .required)
            .field("url", .string, .required)
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(ProfilePicture.schema)
            .delete()
    }
}
