//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    struct ResverUsernamePayloadV1: Content {
        let username: String
        let clientID: UUID
    }
}
