//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Fluent
import FluentPostgresDriver
import Foundation

struct CreatePost: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let coPostApprovalStatus = try await database.enum(CoPostApprovalStatus.schema).read()
        let postType = try await database.enum(PostType.schema).read()
        let mediaType = try await database.enum(MediaType.schema).read()
        
        try await database.schema(PostOwner.schema)
            .id()
            .field("owner_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("co_post_owner_id", .uuid, .references(User.schema, .id, onDelete: .restrict))
            .field("co_post_approval_status", coPostApprovalStatus)
            .create()
        
        try await database.schema(Post.schema)
            .id()
            .field("owner_id", .uuid, .required, .references(PostOwner.schema, .id, onDelete: .cascade))
            .field("description", .string)
            .field("post_type", postType, .required)
            .field("archived", .bool, .required)
            .field("created_at", .datetime, .required)
            .field("modified_at", .datetime, .required)
            .create()
        
        try await database.schema(PostMedia.schema)
            .id()
            .field("post_id", .uuid, .required, .references(Post.schema, .id, onDelete: .cascade))
            .field("media_type", mediaType, .required)
            .field("sensitive_content", .bool, .required)
            .field("name", .string, .required)
            .field("ratio", .float, .required)
            .field("url", .string, .required)
            .field("thumbnail_url", .string)
            .field("storage_location", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PostMedia.schema).delete()
        try await database.schema(Post.schema).delete()
        try await database.schema(PostOwner.schema).delete()
    }
    
}
