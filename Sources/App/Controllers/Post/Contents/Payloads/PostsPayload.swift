//
//  File.swift
//  
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Vapor

final class PostsPayload {
    
    enum V1: Content {
        case me(archived: Bool)
        case user(userID: UUID)
    }
    
}
