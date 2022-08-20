//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

extension TokenController {
    
    struct TokenResponse: Content {
        let accessToken: String?
        let refreshToken: String?
        
        init(accessToken: String? = nil,
             refreshToken: String? = nil) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
        
    }
    
}
