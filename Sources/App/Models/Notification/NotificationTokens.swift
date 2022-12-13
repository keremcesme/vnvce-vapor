//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Vapor
import Fluent
import VNVCECore

final class NotificationToken: Model, Content {
    static let schema = "notification_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Enum(key: "client_os")
    var clientOS: ClientOS
    
    @Field(key: "token")
    var token: String
    
    init() { }
    
    init(token: String, userID: User.IDValue, clientOS: ClientOS) {
        self.token = token
        self.$user.id = userID
        self.clientOS = clientOS
    }
}
