//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    struct SendSMSOTPPayloadV1: Content {
        let phoneNumber: String
        let clientID: UUID
        let type: SMSType
    }
}
