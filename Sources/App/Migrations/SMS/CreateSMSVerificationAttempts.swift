//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent

struct CreateSMSVerificationAttempt: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database
            .schema(SMSVerificationAttempt.schema)
            .id()
            .field("code", .string, .required)
            .field("phone_number", .string, .required)
            .field("client_id", .uuid, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(SMSVerificationAttempt.schema)
            .delete()
    }
    
}
