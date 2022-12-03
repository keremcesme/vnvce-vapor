//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent
import Vapor

final class Username: Model, Content {
    static let schema = "usernames"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init() {}
    
    init(
        username: String,
        user: User.IDValue
    ) {
        self.username  = username
        self.$user.id = user
    }
}

extension User {
    func getUsername(on db: Database) async throws -> String {
        if let username = self.username?.username {
            return username
        } else {
            try await self.$username.load(on: db)
            if let username = self.username?.username {
                return username
            } else if let username = try await self.$username.get(on: db)?.username {
                return username
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
