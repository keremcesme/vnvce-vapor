//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

final class UsernameAvailability {
    
    // MARK: V1
    enum V1: String, Content {
        case available = "available"
        case alreadyTaken = "alreadyTaken"
        case reserved = "reserved"
    }
    
}

extension UsernameAvailability.V1 {
    
    func message(_ username: String) -> String {
        switch self {
            case .available:
                return "The username \"\(username)\" is available."
            case .reserved:
                return "The username \"\(username)\" is reserved."
            case .alreadyTaken:
                return "The username \"\(username)\" is already taken."
        }
    }
}
