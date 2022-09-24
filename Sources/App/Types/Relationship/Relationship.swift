//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Vapor

final class Relationship {
    
    enum V1: String, Content {
        case nothing
        case friend
        case friendRequestSubmitted = "friend_request_submitted"
        case friendRequestReceived = "friend_request_received"
        case targetUserBlocked = "target_user_blocked"
        case blocked
    }
    
}
