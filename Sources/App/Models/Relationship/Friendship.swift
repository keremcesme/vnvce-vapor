//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Fluent
import Vapor

final class Friendship: Model, Content {
    static let schema = "friendships"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_1_id")
    var user1: User
    
    @Parent(key: "user_2_id")
    var user2: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(user1: User.IDValue, user2: User.IDValue) {
        self.$user1.id = user1
        self.$user2.id = user2
    }
}
