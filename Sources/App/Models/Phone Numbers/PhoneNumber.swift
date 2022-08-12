//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Fluent
import Vapor

final class PhoneNumber: Model, Content {
    static let schema = "phone_numbers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init() {}
    
    init(
        phoneNumber: String,
        user: User.IDValue
    ) {
        self.phoneNumber  = phoneNumber
        self.$user.id = user
    }
}
