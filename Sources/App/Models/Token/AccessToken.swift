//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Fluent
import Vapor
import Foundation

final class AccessToken: Model, Content {
    static let schema = "access_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "refresh_token_id")
    var refreshToken: RefreshToken
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "client_id")
    var clientID: UUID
        
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        userID: User.IDValue,
        refreshTokenID: RefreshToken.IDValue,
        token: String,
        clientID: UUID,
        expiresAt: Date
    ) {
        self.$user.id = userID
        self.$refreshToken.id = refreshTokenID
        self.token = token
        self.clientID = clientID
        self.expiresAt = expiresAt
    }
}

extension AccessToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<AccessToken, Field<String>> {
        \.$token
    }

    static var userKey: KeyPath<AccessToken, Parent<User>> {
        \.$user
    }
    
    var isValid: Bool {
        return expiresAt > Date()
    }
}

extension AccessToken {
    static func generate(userID: UUID, refreshTokenID: UUID, clientID: UUID) -> AccessToken {
        let token = [UInt8].random(count: 16).base64
        let expiresAt =  Date().addingTimeInterval(3600)
        
        let accessToken = AccessToken(
            userID: userID,
            refreshTokenID: refreshTokenID,
            token: token,
            clientID: clientID,
            expiresAt: expiresAt
        )
        
        return accessToken
    }
}
