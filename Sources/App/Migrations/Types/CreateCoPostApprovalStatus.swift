//
//  File.swift
//  
//
//  Created by Kerem Cesme on 13.09.2022.
//

import Fluent
import FluentPostgresDriver
import Foundation

struct CreateCoPostApprovalStatus: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(CoPostApprovalStatus.schema)
            .case("pending")
            .case("approved")
            .case("rejected")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .enum(CoPostApprovalStatus.schema)
            .delete()
    }
}
