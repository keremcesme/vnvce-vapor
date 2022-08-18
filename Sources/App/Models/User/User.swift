//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Fluent
import Vapor

struct UserModel: Content {
    let id: UUID
    let username: String
    let phoneNumber: String
    
    let displayName: String?
    let biography: String?
}

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "display_name")
    var displayName: String?
    
    @OptionalField(key: "biography")
    var biography: String?
    
    @OptionalChild(for: \.$user)
    var username: Username?
    
    @OptionalChild(for: \.$user)
    var phoneNumber: PhoneNumber?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init() {}
    
    init(displayName: String? = nil, biography: String? = nil) {
        self.displayName = displayName
        self.biography = biography
    }
    
    struct Private: Content {
        let id: UUID
        let username: String
        let phoneNumber: String
        let displayName: String?
        let biography: String?
    }
    
    struct Public: Content {
        let id: UUID
        let username: String
        let displayName: String?
        let biography: String?
    }
    
}

// MARK: Private User
extension User {
    
    func convertToPrivate(_ req: Request) async throws -> User.Private {
        try await self.$username.load(on: req.db)
        try await self.$phoneNumber.load(on: req.db)
        
        return User.Private(
            id: try self.requireID(),
            username: self.username!.username,
            phoneNumber: self.phoneNumber!.phoneNumber,
            displayName: self.displayName,
            biography: self.biography
        )
    }
    
    func convertToPrivate(_ db: Database) async throws -> User.Private {
        try await self.$username.load(on: db)
        try await self.$phoneNumber.load(on: db)
        
        return User.Private(
            id: try self.requireID(),
            username: self.username!.username,
            phoneNumber: self.phoneNumber!.phoneNumber,
            displayName: self.displayName,
            biography: self.biography
        )
    }
}

// MARK: pUBLIC User
extension User {
    func convertToPublic(_ req: Request) async throws -> User.Public {
        try await self.$username.load(on: req.db)
        try await self.$phoneNumber.load(on: req.db)
        
        return User.Public(
            id: try self.requireID(),
            username: self.username!.username,
            displayName: self.displayName,
            biography: self.biography
        )
    }
    
    func convertToPublic(_ db: Database) async throws -> User.Public {
        try await self.$username.load(on: db)
        try await self.$phoneNumber.load(on: db)
        
        return User.Public(
            id: try self.requireID(),
            username: self.username!.username,
            displayName: self.displayName,
            biography: self.biography
        )
    }
}
