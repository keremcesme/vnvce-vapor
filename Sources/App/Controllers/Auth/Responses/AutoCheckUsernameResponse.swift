//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    struct AutoCheckUsernameResponseV1: Content {
        let status: UsernameAvailability
    }

}
