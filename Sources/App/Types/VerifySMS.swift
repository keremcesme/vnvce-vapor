//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

struct VerifySMSPayload: Content {
    let phoneNumber: String
    let otpCode: String
    let clientID: UUID
    let attemptID: UUID
}

enum SMSVerificationResult: String, Content {
    case verified = "verified"
    case expired = "expired"
    case failure = "failure"
}
