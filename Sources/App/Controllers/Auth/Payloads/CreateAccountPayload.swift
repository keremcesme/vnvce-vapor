//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    struct CreateAccountPayloadV1: Content {
        let otp: VerifySMSPayload
        let username: String
    }
}
