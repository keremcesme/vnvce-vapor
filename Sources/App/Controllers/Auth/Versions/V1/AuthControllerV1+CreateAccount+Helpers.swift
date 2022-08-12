//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor
import Fluent

// MARK: Auth Controller V1 - Create Account - Helpers
extension AuthController {
    
    func checkPhoneNumberAvailabilityV1(phoneNumber: String, _ req: Request) async throws -> PhoneNumberAvailability{
        
        guard try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .first() == nil else {
            return .alreadyTaken
        }
        
        var otpAttempts = try await SMSVerificationAttempt.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .sort(\.$createdAt, .descending)
            .all()
        
        if !otpAttempts.isEmpty, let lastOTP = otpAttempts.first {
            otpAttempts.removeFirst()
            
            try await otpAttempts.delete(force: true, on: req.db)
            
            guard lastOTP.expiresAt < Date() else {
                return .otpExist
            }
            try await lastOTP.delete(force: true, on: req.db)
            return .available
        } else {
            return .available
        }
        
    }
    
    func checkUsernameAvailabilityV1(username: String, _ req: Request) async throws -> UsernameAvailability {
        
        guard try await Username.query(on: req.db)
            .filter(\.$username == username)
            .first() == nil else {
            return .alreadyTaken
        }
        
        var reservedUsernames = try await ReservedUsername.query(on: req.db)
            .filter(\.$username == username)
            .sort(\.$createdAt, .descending)
            .all()
        
        if !reservedUsernames.isEmpty, let lastUsername = reservedUsernames.first {
            reservedUsernames.removeFirst()
            
            try await reservedUsernames.delete(force: true, on: req.db)
            
            guard lastUsername.expiresAt < Date() else {
                return .reserved
            }
            
            try await lastUsername.delete(force: true, on: req.db)
            return.available
        } else {
            return .available
        }
    }
    
    func verifySMSV1(otp: VerifySMSPayload, _ req: Request) async throws -> SMSVerificationResult {
        
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
