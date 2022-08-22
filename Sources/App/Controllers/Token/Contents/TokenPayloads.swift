//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class GenerateTokensPayload {
    
    struct V1: Content {
        let userID: UUID
        let refreshToken: String
        let clientID: UUID
    }
    
}
