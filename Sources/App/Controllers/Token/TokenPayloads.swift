//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

extension TokenController {
    
    struct GenerateTokensPayload: Content {
        let userID: UUID
        let refreshToken: String
        let clientID: UUID
    }
    
}
