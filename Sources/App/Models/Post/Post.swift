//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owners_id")
    var owner: PostOwner
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "archived")
    var archived: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init(){}
    
    init(
        ownerID: PostOwner.IDValue,
        description: String?,
        archived: Bool
    ){
        self.$owner.id = ownerID
        self.description = description
        self.archived = archived
    }
}
