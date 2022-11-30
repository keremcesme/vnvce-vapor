//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    struct CheckUsernamePayload: Content, Codable {
        let clientID: String
        let username: String
        let phoneNumber: String
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
            case username
            case phoneNumber = "phone_number"
        }
    }
}
