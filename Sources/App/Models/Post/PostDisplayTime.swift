//
//  File.swift
//  
//
//  Created by Kerem Cesme on 5.10.2022.
//

import Fluent
import Vapor

final class PostDisplayTime: Model, Content {
    static let schema = "post_display_times"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "post_id")
    var post: Post
    
    @Parent(key: "owner_id")
    var owner: User
    
    @Field(key: "second")
    var second: Double
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init(){}
    
    init(
        postID: Post.IDValue,
        ownerID: User.IDValue,
        second: Double
    ) {
        self.$post.id = postID
        self.$owner.id = ownerID
        self.second = second
    }
    
    struct V1: Content {
        let id: UUID
        let second: Double
    }
    
}

extension PostDisplayTime {
    func convertDisplayTime() throws -> PostDisplayTime.V1 {
        return PostDisplayTime.V1(id: try self.requireID(), second: self.second)
    }
}
