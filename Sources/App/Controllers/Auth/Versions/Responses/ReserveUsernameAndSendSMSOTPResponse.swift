//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

extension AuthController {
    struct ReserveUsernameAndSendSMSOTPSuccessV1: Content {
        let attemptID: UUID
        let startTime: TimeInterval
        let expiryTime: TimeInterval
    }
    
    enum ReserveUsernameAndSendSMSOTPErrorV1: Content {
        case phone(SendSMSOTPFailure)
        case username(ReserveUsernameFailure)
    }
    
    enum ReserveUsernameAndSendSMSOTPStatus: Content {
        case success(SendSMSOTPAttempt)
        case failure(ReserveUsernameAndSendSMSOTPErrorV1)
    }
    
    struct ReserveUsernameAndSendSMSOTPResponseV1: Content {
        var status: ReserveUsernameAndSendSMSOTPStatus
    }
    
}

