//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

final class FriendRequest: Model, Content {
    static let schema = "friend_requests"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "submitted_user_id")
    var submittedUser: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        user: User.IDValue,
        submittedUser: User.IDValue
    ) {
        self.$user.id = user
        self.$submittedUser.id = submittedUser
    }
}
