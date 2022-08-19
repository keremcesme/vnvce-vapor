//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

struct SendSMSOTPAttempt: Content {
    let attemptID: UUID
    let startTime: TimeInterval
    let expiryTime: TimeInterval
}

enum SendSMSOTPFailure: String, Content {
    case alreadyTaken = "alreadyTaken"
    case otpExist = "otpExist"
}

extension SendSMSOTPFailure {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .alreadyTaken:
                return "The phone number \"\(phoneNumber)\" is already taken."
        }
    }
}

enum SendSMSOTPResult: Content {
    case success(SendSMSOTPAttempt)
    case failure(SendSMSOTPFailure)
}


