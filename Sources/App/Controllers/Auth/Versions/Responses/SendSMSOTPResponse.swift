//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    enum SendSMSOTPStatus: Content {
        case sended(UUID)
        case failure(PhoneNumberAvailability)
    }
    
    struct SendSMSOTPResponseV1: Content {
        var status: SendSMSOTPStatus
    }
    
}
