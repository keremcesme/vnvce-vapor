//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

final class PostOwner: Model, Content {
    static let schema = "post_owners"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_1_id")
    var user1: User
    
    @OptionalParent(key: "user_2_id")
    var user2: User?
    
    @OptionalChild(for: \.$owner)
    var post: Post?
    
    init(){}
    
    init(
        user1id : User.IDValue,
        user2id : User.IDValue? = nil
    ){
        self.$user1.id = user1id
        self.$user2.id = user2id
    }
    
}
