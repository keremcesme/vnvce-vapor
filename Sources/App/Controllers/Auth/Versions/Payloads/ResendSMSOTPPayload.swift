//
//  File.swift
//  
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Vapor

extension AuthController {
    struct ResendSMSOTPPayloadV1: Content {
        let phoneNumber: String
        let clientID: UUID
        let type: SMSType
        
    }
}
