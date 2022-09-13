//
//  File.swift
//  
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Fluent
import FluentPostgresDriver
import Foundation

struct CreatePostType: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(PostType.schema)
            .case("single")
            .case("co_post")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(PostType.schema).delete()
    }
}
