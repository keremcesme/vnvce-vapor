//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Fluent

struct CreateNotificationToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        let deviceOS = try await database.enum(DeviceOS.schema).read()
        
        try await database
            .schema(NotificationToken.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("device_os", deviceOS, .required)
            .field("token", .string, .required)
            .unique(on: "token", name: "uk_notification_token")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(NotificationToken.schema)
            .delete()
    }
    
}
