//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor
import Foundation

extension AuthController {
    
    struct SendSMSOtpSuccessV1: Content {
        let attemptID: UUID
        let startTime: TimeInterval
        let expiryTime: TimeInterval
    }
    
    enum SendSMSOTPStatus: Content {
        case sended(SendSMSOtpSuccessV1)
        case failure(PhoneNumberAvailability)
    }
    
    struct SendSMSOTPResponseV1: Content {
        var status: SendSMSOTPStatus
    }
    
}
