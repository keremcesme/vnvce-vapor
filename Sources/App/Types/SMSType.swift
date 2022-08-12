//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Vapor

enum SMSType: String, Content {
    case login = "login"
    case createAccount = "createAccount"
}

extension SMSType {
    
    func message(code: String) -> String {
        
        let type: String = {
            switch self {
                case .login:
                    return "logging into"
                case .createAccount:
                    return "creating"
            }
        }()
        
        var message = "Verification code for \(type) vnvce account: \(code).\nIf you did not request this, disregard this message."
        
        return message
    }
}

/*
Verification code for creating vnvce account: \(code).
Verification code for logging into vnvce account: \(code).
 */
