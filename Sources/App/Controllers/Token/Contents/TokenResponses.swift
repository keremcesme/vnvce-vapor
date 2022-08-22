//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class TokenGenerateError {
    enum V1: String, Content {
        case notFound = "No Found Refresh Token in the database"
        case clientIdNotMatch = "Client ID not match."
    }
}

final class GeneratedTokens {
    struct V1: Content {
        let accessToken: String?
        let refreshToken: String?
        
        init(accessToken: String? = nil,
             refreshToken: String? = nil) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
        
    }
}

extension GeneratedTokens.V1 {
    var message: String {
        if accessToken != nil && refreshToken != nil {
           return "Access and Refresh Tokens generated."
        } else if accessToken != nil && refreshToken == nil {
            return "Access Token is generated."
        } else {
            return "Unknown"
        }
    }
}

final class TokenResponse {
    enum V1: Content {
        case failure(TokenGenerateError.V1)
        case success(GeneratedTokens.V1)
    }
    
}
