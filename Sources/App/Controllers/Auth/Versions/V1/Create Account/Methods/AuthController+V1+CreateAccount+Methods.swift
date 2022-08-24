//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor


// MARK: AuthController V1 - Create Account - Methods -
extension AuthController.V1.CreateAccount {
    
    // Step 1 - Check phone number availability.
    func checkPhoneNumberHandler(_ req: Request) async throws -> Response<PhoneNumberAvailability.CreateV1> {
        guard let phoneNumber = req.parameters.get("phone_number"),
              let clientIDString = req.parameters.get("client_id"),
              let clientID = UUID(uuidString: clientIDString)
        else {
            throw Abort(.notFound, reason: "'phone_number' or 'client_id' parameter is missing.")
        }
        
        let result = try await checkPhoneNumberAvailability(
            phoneNumber: phoneNumber,
            clientID: clientID,
            req)
        
        let availability = result.availability
        
        return Response(result: availability, message: availability.message(phoneNumber))
    }
    
    // Auto Check username availabiltiy.
    func autoCheckUsernameHandler(_ req: Request) async throws -> Response<UsernameAvailability.V1> {
        guard let username = req.parameters.get("username"),
              let clientIDString = req.parameters.get("client_id"),
              let clientID = UUID(uuidString: clientIDString)
        else {
            throw Abort(.notFound, reason: "'username' or 'client_id' parameter is missing.")
        }
        
        let availability = try await checkUsernameAvailability(
            username: username,
            clientID: clientID,
            req)
        
        return Response(result: availability, message: availability.message(username))
    }
    
    // Step 2 - Reserve Username and Send OTP code to phone number.
    func reserveUsernameAndSendSMSOTPHandler(_ req: Request) async throws -> Response<ReserveUsernameAndSendSMSOTPResponse.V1> {
        let payload = try req.content.decode(ReserveUsernameAndSendSMSOTPPayload.V1.self)
        let username = payload.username
        let phoneNumber = payload.phoneNumber
        let clientID = payload.clientID
        let type = payload.type
        
        let reserveResult = try await reserveUsername(
            username: username,
            clientID: clientID,
            req)
        
        switch reserveResult {
            case let .failure(error):
                return Response(result: .failure(.username(error)), message: error.message(username))
            case .success:
                let sendOTPResult = try await sendSMSOTP(
                    phoneNumber: phoneNumber,
                    clientID: clientID,
                    type: type,
                    req)
                
                switch sendOTPResult {
                    case let .failure(error):
                        return Response(result: .failure(.phone(error)), message: error.message(phoneNumber))
                    case let .success(attempt):
                        return Response(result: .success(attempt), message: "SMS is sended.")
                }
        }
    }
    
    // Optional - Resend SMS OTP.
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
    
    // Step 3 - Verify OTP and create account.
    func createAccountHandler(_ req: Request) async throws -> Response<AccountResponse.V1> {
        let payload = try req.content.decode(CreateAccountPayload.V1.self)
        let otp = payload.otp
        let username = payload.username
        
        let otpVerificationResult = try await verifySMS(otp: payload.otp, req)
        
        switch otpVerificationResult {
            case .failure:
                return Response(result: .failure(.failure), message: "Failure")
            case .expired:
                return Response(result: .failure(.expired), message: "Expired")
            case .verified:
                let response = try await createUser(username: username, otp: otp, req)
                print(response)
                return Response(result: .success(response), message: "Account created succesfully.")
        }
    }
    
}
