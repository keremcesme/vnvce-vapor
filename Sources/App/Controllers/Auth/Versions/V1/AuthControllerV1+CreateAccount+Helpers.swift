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
    
    func verifySMSV1(
        otp: VerifySMSPayload,
        _ req: Request
    ) async throws -> SMSVerificationResult {
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
    
    // MARK: Create Account: User(1), Phone Number(2), Username(2), Tokens(3)
    func createUserV1(
        username: String,
        otp: VerifySMSPayload,
        _ req: Request
    ) async throws -> CreateAccountSuccessV1 {
        let clientID = otp.clientID
        let phoneNumber = otp.phoneNumber
        
        let user = User()
        
        let result: CreateAccountSuccessV1 = try await req.db.transaction({
            try await user.create(on: $0)
            let userID = try user.requireID()
            
            try await createPhoneNumberAndUsernameV1(
                phoneNumber: phoneNumber,
                username: username,
                userID: userID,
                db: $0)
            
            let tokens = try await createTokensV1(
                userID: userID,
                clientID: clientID,
                db: $0)
            
            let user = try await user.convertToPrivate($0)
            
            return CreateAccountSuccessV1(user: user, tokens: tokens)
        })
        
        return result
    }
    
    private func createPhoneNumberAndUsernameV1(
        phoneNumber: String,
        username: String,
        userID: UUID,
        db: Database
    ) async throws {
        let phoneNumber = PhoneNumber(phoneNumber: phoneNumber, user: userID)
        let username = Username(username: username, user: userID)
        
        try await phoneNumber.create(on: db)
        try await username.create(on: db)
        
        try await ReservedUsername.query(on: db)
            .filter(\.$username == username.username)
            .delete(force: true)
    }
    
    private func createTokensV1(
        userID: UUID,
        clientID: UUID,
        db: Database
    ) async throws -> Tokens {
        let refreshToken = try RefreshToken.generate(
            userID: userID,
            clientID: clientID)
        
        try await refreshToken.create(on: db)
        
        let accessToken = try AccessToken.generate(
            userID: userID,
            refreshTokenID: try refreshToken.requireID(),
            clientID: clientID)
        
        try await accessToken.create(on: db)
        
        return Tokens(accessToken: accessToken.token, refreshToken: refreshToken.token)
    }
}
