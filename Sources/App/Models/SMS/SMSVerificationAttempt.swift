//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor
import Foundation

final class SMSVerificationAttempt: Model, Content {
    static let schema = "sms_verification_attempts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Field(key: "code")
    var code: String
    
    @Field(key: "client_id")
    var clientID: UUID
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(code: String, phoneNumber: String, clientID: UUID, expiresAt: Date) {
        self.code = code
        self.phoneNumber = phoneNumber
        self.clientID = clientID
        self.expiresAt = expiresAt
    }
    
}

struct SMSOTPAttempt: Content {
    let attemptID: UUID
    let startTime: TimeInterval
    let expiryTime: TimeInterval
}
