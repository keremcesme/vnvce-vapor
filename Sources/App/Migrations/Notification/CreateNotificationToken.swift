//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Fluent
import VNVCECore

struct CreateNotificationToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        let clientOS = try await database.enum(ClientOS.schema).read()
        
        try await database
            .schema(NotificationToken.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("client_os", clientOS, .required)
            .field("token", .string, .required)
            .unique(on: "user_id", name: "notification_tokens_user_id_ukey")
            .unique(on: "token", name: "notification_tokens_token_ukey")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(NotificationToken.schema)
            .delete()
    }
    
}
