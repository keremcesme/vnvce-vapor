//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent
import Vapor
import Foundation

final class RefreshToken: Model, Content {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "client_id")
    var clientID: UUID
    
    @OptionalChild(for: \.$refreshToken)
    var accessToken: AccessToken?
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        userID: User.IDValue,
        token: String,
        clientID: UUID,
        expiresAt: Date
    ) {
        self.$user.id = userID
        self.token = token
        self.clientID = clientID
        self.expiresAt = expiresAt
    }
}

extension RefreshToken {
    static func generate(userID: UUID, clientID: UUID) -> RefreshToken {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let token = String((0 ... 40).map { _ in letters.randomElement()! })
        let expiresAt =  Date().addingTimeInterval(3600 * 24 * 30)
        
        let refreshToken = RefreshToken(
            userID: userID,
            token: token,
            clientID: clientID,
            expiresAt: expiresAt
        )
        
        return refreshToken
    }
}
