//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class ReserveUsernameError {
    // MARK: V1
    enum V1: String, Content {
        case alreadyTaken = "alreadyTaken"
        case reserved = "reserved"
    }
    // ...
}

extension ReserveUsernameError.V1 {
    func message(_ username: String) -> String {
        switch self {
            case .alreadyTaken:
                return "The username \"\(username)\" is already taken."
            case .reserved:
                return "The username \"\(username)\" is reserved."
        }
    }
}
