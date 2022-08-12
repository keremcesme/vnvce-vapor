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

final class User: Model, Content {
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
    
}

extension User {
    
    func convertToPulbic(_ req: Request) async throws -> UserModel {
        try await self.$username.load(on: req.db)
        try await self.$phoneNumber.load(on: req.db)
        
        return UserModel(id: try self.requireID(),
                         username: self.username!.username,
                         phoneNumber: self.phoneNumber!.phoneNumber,
                         displayName: self.displayName,
                         biography: self.biography)
    }
    
    func convertToPulbic(_ db: Database) async throws -> UserModel {
        try await self.$username.load(on: db)
        try await self.$phoneNumber.load(on: db)
        
        return UserModel(id: try self.requireID(),
                         username: self.username!.username,
                         phoneNumber: self.phoneNumber!.phoneNumber,
                         displayName: self.displayName,
                         biography: self.biography)
    }
    
}
