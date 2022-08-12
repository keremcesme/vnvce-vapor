//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent
import Vapor

final class ReservedUsername: Model, Content {
    static let schema = "reserved_usernames"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "client_id")
    var clientID: UUID
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        username: String,
        clientID: UUID,
        expiresAt: Date
    ) {
        self.username = username
        self.clientID = clientID
        self.expiresAt = expiresAt
    }
}
