//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import FluentPostgresDriver
import FluentPostGIS
import Foundation
import VNVCECore

struct CreateMoment: AsyncMigration {
    func prepare(on database: Database) async throws {
        let month = try await database.enum(Month.schema).read()
        let mediaType = try await database.enum(MediaType.schema).read()
        
//        try await database.schema(MomentDay.schema)
//            .id()
//            .field("owner_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
//            .field("day", .int, .required)
//            .field("month", month, .required)
//            .field("year", .int, .required)
//            .field("created_at", .datetime, .required)
//            .field("modified_at", .datetime, .required)
//            .create()
//
//        try await database.schema(Moment.schema)
//            .id()
//            .field("owner_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
//            .field("day_id", .uuid, .required, .references(MomentDay.schema, .id, onDelete: .cascade))
//            .field("created_at", .datetime, .required)
//            .create()
//
//        try await database.schema(MomentMedia.schema)
//            .id()
//            .field("moment_id", .uuid, .required, .references(Moment.schema, .id, onDelete: .cascade))
//            .field("media_type", mediaType, .required)
//            .field("name", .string, .required)
//            .field("url", .string, .required)
//            .field("thumbnail_url", .string)
//            .field("sensitive_content", .bool, .required)
//            .create()
        
        try await database.schema(Moment.schema)
            .id()
            .field("owner_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("media_type", mediaType, .required)
            .field("name", .string, .required)
            .field("url", .string, .required)
            .field("thumbnail_url", .string)
            .field("sensitive_content", .bool, .required)
            .field("location", .geometricPoint2D)
            .field("created_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
//        try await database.schema(MomentMedia.schema).delete()
        try await database.schema(Moment.schema).delete()
//        try await database.schema(MomentDay.schema).delete()
    }
}
