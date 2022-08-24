//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.08.2022.
//

import Vapor
import Fluent

// MARK: AuthController V1 - Login - Phone Number - Helper -
extension AuthController.V1.Login {
    func checkPhoneNumberAvailability(
        phoneNumber: String,
        clientID: UUID,
        _ req: Request
    ) async throws -> CheckPhoneNumberAvailabilityResult<PhoneNumberAvailability.LoginV1>{
        guard try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .first() != nil else {
            return (.notFound, nil)
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
    
    func sendSMSOTP(
        phoneNumber: String,
        clientID: UUID,
        type: SMSType,
        _ req: Request
    ) async throws -> SendSMSOTPResult.V1 {
        let result = try await checkPhoneNumberAvailability(
            phoneNumber: phoneNumber,
            clientID: clientID,
            req)
        
        switch result.availability {
            case .notFound:
                return .failure(.notFound)
            case .otpExist:
                return .failure(.otpExist)
            case .available:
                if let attempt = result.attempt,
                   let startTime = attempt.createdAt?.timeIntervalSince1970 {
                    let otpAttempt = SMSOTPAttempt(
                        attemptID: try attempt.requireID(),
                        startTime: startTime,
                        expiryTime: attempt.expiresAt.timeIntervalSince1970)
                    
                    return .success(otpAttempt)
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
                    
                    let otpAttempt = SMSOTPAttempt(
                        attemptID: attemptID,
                        startTime: startTime,
                        expiryTime: expiryTime.timeIntervalSince1970)
                    
                    return .success(otpAttempt)
                }
        }
    }
    
    func verifySMS(
        otp: VerifySMSPayload.V1,
        _ req: Request
    ) async throws -> SMSVerificationResult.V1 {
        guard let attempt = try await SMSVerificationAttempt.query(on: req.db)
            .filter(\.$id == otp.attemptID)
            .filter(\.$phoneNumber == otp.phoneNumber)
            .filter(\.$code == otp.otpCode)
            .filter(\.$clientID == otp.clientID)
            .first() else {
            return .failure
        }
        
        guard attempt.expiresAt > Date() else {
            return .expired
        }
        
        try await attempt.delete(force: true, on: req.db)
        return .verified
    }
    
}
