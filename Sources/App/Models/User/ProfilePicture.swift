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
    
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "name")
    var name: String
    
    init() {}
    
    init(
        userID: User.IDValue,
        url: String,
        name: String
    ) {
        self.$user.id = userID
        self.url = url
        self.name = name
    }
    
    struct Details: Content {
        let url: String
        let name: String
    }
    
}

extension ProfilePicture {
    func convert() -> ProfilePicture.Details {
        return ProfilePicture.Details(url: self.url, name: self.name)
    }
}
