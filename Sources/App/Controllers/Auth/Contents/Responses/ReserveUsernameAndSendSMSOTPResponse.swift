//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

final class ReserveUsernameAndSendSMSOTPError {
    // MARK: V1
    enum V1: Content {
        case phone(SendSMSOTPError.V1)
        case username(ReserveUsernameError.V1)
    }
}

final class ReserveUsernameAndSendSMSOTPResponse {
    // MARK: V1
    enum V1: Content {
        case success(SMSOTPAttempt)
        case failure(ReserveUsernameAndSendSMSOTPError.V1)
    }
}

//extension AuthController.V1.CreateAccount {
//    
//    enum ReserveUsernameAndSendSMSOTPError: Content {
//        case phone(SendSMSOTPError.V1)
//        case username(ReserveUsernameError.V1)
//    }
//    
//    enum ReserveUsernameAndSendSMSOTPResponse: Content {
//        case success(SMSOTPAttempt)
//        case failure(ReserveUsernameAndSendSMSOTPError)
//    }
//}

// MARK: OLD

//extension AuthController {
//    struct ReserveUsernameAndSendSMSOTPSuccessV1: Content {
//        let attemptID: UUID
//        let startTime: TimeInterval
//        let expiryTime: TimeInterval
//    }
//
//    enum ReserveUsernameAndSendSMSOTPErrorV1: Content {
//        case phone(SendSMSOTPFailure)
//        case username(ReserveUsernameFailure)
//    }
//
//    enum ReserveUsernameAndSendSMSOTPStatus: Content {
//        case success(SMSOTPAttempt)
//        case failure(ReserveUsernameAndSendSMSOTPErrorV1)
//    }
//
//    struct ReserveUsernameAndSendSMSOTPResponseV1: Content {
//        var status: ReserveUsernameAndSendSMSOTPStatus
//    }
//
//}


