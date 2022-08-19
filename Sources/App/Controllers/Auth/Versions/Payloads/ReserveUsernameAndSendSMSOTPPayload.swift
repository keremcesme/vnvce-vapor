//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

extension AuthController {
    struct ReserveUsernameAndSendSMSOTPPayloadV1: Content {
        let username: String
        let phoneNumber: String
        let clientID: UUID
        let type: SMSType
    }
}
