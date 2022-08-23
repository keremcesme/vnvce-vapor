//
//  File.swift
//  
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Fluent
import FluentPostgresDriver

struct CreateProfilePictureAlignmentType: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(ProfilePictureAlignmentType.schema)
            .case("top")
            .case("center")
            .case("bottom")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(ProfilePictureAlignmentType.schema).delete()
    }
}
