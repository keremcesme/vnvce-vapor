//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController V1 - Login - Methods -
extension AuthController.V1.Login {
    
    func sendSMSOTPHandler(_ req: Request) async throws -> SendSMSOTPResult.V1 {
        let payload = try req.content.decode(SendSMSOTPPayload.V1.self)
        let phoneNumber = payload.phoneNumber
        let clientID = payload.clientID
        let type = payload.type
        
        return try await sendSMSOTP(
            phoneNumber: phoneNumber,
            clientID: clientID,
            type: type, req)
        
    }
    
    func verifySMSOTPHandler(_ req: Request) async throws -> Response<AccountResponse.V1> {
        let otp = try req.content.decode(VerifySMSPayload.V1.self)
        
        let result = try await verifySMS(otp: otp, req)
        
        switch result {
            case .failure:
                return Response(result: .failure(.failure), message: "Failure")
            case .expired:
                return Response(result: .failure(.expired), message: "Expired")
            case .verified:
                let response = try await login(otp: otp, req)
                return Response(result: .success(response), message: "Account created succesfully.")
        }
    }
    
    func resendSMSOTPHandler(_ req: Request) async throws -> Response<SMSOTPAttempt> {
        let payload = try req.content.decode(SendSMSOTPPayload.V1.self)
        let phoneNumber = payload.phoneNumber
        let clientID = payload.clientID
        let type = payload.type
        
        try await SMSVerificationAttempt.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$clientID == clientID)
            .delete()
        
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
        
        return Response(result: otpAttempt, message: "SMS is resended.")
    }
    
}
