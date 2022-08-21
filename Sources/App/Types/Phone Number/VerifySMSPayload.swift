//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

final class VerifySMSPayload {
    // MARK: V1
    struct V1: Content {
        let phoneNumber: String
        let otpCode: String
        let clientID: UUID
        let attemptID: UUID
    }
}




