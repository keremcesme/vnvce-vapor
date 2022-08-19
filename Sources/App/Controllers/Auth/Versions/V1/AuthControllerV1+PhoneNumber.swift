//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor
import Fluent

// MARK: Auth Controller V1 - Phone Number - Helpers
extension AuthController {
    func checkPhoneNumberAvailabilityV1(
        phoneNumber: String,
        clientID: UUID,
        _ req: Request
    ) async throws -> (PhoneNumberAvailability, SMSVerificationAttempt?) {
        
        guard try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .first() == nil else {
            return (.alreadyTaken, nil)
        }
        
        var otpAttempts = try await SMSVerificationAttempt.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .sort(\.$createdAt, .descending)
            .all()
        
        if !otpAttempts.isEmpty, let lastOTP = otpAttempts.first {
            otpAttempts.removeFirst()
            
            try await otpAttempts.delete(force: true, on: req.db)
            
            guard lastOTP.expiresAt < Date() else {
                let id = lastOTP.clientID
                if id == clientID {
                    return (.available, lastOTP)
                } else {
                    return (.otpExist, nil)
                }
            }
            try await lastOTP.delete(force: true, on: req.db)
            return (.available, nil)
        } else {
            return (.available, nil)
        }
    }
    
    func sendSMSOTPV1(
        phoneNumber: String,
        clientID: UUID,
        type: SMSType,
        _ req: Request
    ) async throws -> SendSMSOTPResult {
        let availability = try await checkPhoneNumberAvailabilityV1(
            phoneNumber: phoneNumber, clientID: clientID, req)
        
        switch availability.0 {
            case .alreadyTaken:
                return .failure(.alreadyTaken)
            case .otpExist:
                return .failure(.otpExist)
            case .available:
                if let attempt = availability.1 {
                    let id = try attempt.requireID()
                    return .success(SendSMSOTPAttempt(
                        attemptID: id,
                        startTime: attempt.createdAt!.timeIntervalSince1970,
                        expiryTime: attempt.expiresAt.timeIntervalSince1970))
                } else {
                    let otpCode = String.randomDigits(ofLength: 6)
                    
                    _ = try await req.application.smsSender!
                        .sendSMS(to: phoneNumber, message: type.message(code: otpCode), on: req.eventLoop)
                    
                    let startTime = Date().timeIntervalSince1970
                    let expiryTime = Date().addingTimeInterval(60)
                    let attempt = SMSVerificationAttempt(
                        code: otpCode,
                        phoneNumber: phoneNumber,
                        clientID: clientID,
                        expiresAt: expiryTime)
                    
                    try await attempt.create(on: req.db)
                    let attemptID = try attempt.requireID()
                    
                    return .success(SendSMSOTPAttempt(
                        attemptID: attemptID,
                        startTime: startTime,
                        expiryTime: expiryTime.timeIntervalSince1970))
                }
                
        }
    }
    
    
}
