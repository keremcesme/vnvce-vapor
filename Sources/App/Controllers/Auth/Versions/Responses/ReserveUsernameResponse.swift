//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    enum ReserveUsernameStatus: Content {
        case success
        case failure(UsernameAvailability)
    }
    
    struct ReserveUsernameResponseV1: Content {
        var status: ReserveUsernameStatus
    }
}
