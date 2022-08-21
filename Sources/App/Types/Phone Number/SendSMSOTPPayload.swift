//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class SendSMSOTPPayload {
    
    // MARK: V1
    struct V1: Content {
        let phoneNumber: String
        let clientID: UUID
        let type: SMSType
    }
}
