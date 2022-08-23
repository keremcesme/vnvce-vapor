//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor

final class ProfilePicture: Model, Content, Authenticatable {
    static let schema = "profile_pictures"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalEnum(key: "alignment")
    var alignment: ProfilePictureAlignmentType?
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "name")
    var name: String
    
    init() {}
    
    init(
        userID: User.IDValue,
        alignment: ProfilePictureAlignmentType? = nil,
        url: String,
        name: String
    ) {
        self.$user.id = userID
        self.alignment = alignment
        self.url = url
        self.name = name
    }
    
}
