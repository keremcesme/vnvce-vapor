//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

enum ReserveUsernameFailure: String, Content {
    case alreadyTaken = "alreadyTaken"
    case reserved = "reserved"
}

extension ReserveUsernameFailure {
    func message(_ username: String) -> String {
        switch self {
            case .alreadyTaken:
                return "The username \"\(username)\" is already taken."
            case .reserved:
                return "The username \"\(username)\" is reserved."
        }
    }
}

enum ReserveUsernameResult: Content {
    case success
    case failure(ReserveUsernameFailure)
}
