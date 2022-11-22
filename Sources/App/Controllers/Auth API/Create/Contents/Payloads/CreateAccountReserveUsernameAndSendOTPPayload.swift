//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    struct ReserveUsernameAndSendOTPPayload: Content, Codable {
        let username: String
        let phoneNumber: String
        let clientID: String
        
        enum CodingKeys: String, CodingKey {
            case username
            case phoneNumber = "phone_number"
            case clientID = "client_id"
        }
    }
}
