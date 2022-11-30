//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    
    enum UsernameAvailability {
        case available
        case userHasAlreadyReserved
        case alreadyTaken
        case reserved
        
        var message: String {
            switch self {
            case .available:
                return "Username is available."
            case .userHasAlreadyReserved:
                return "User has already reserved the username."
            case .alreadyTaken:
                return "Username is already in use."
            case .reserved:
                return "Username is reserved."
            }
        }
    }
    
}
