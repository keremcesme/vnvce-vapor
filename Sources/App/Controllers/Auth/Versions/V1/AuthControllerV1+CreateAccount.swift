//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor
import Foundation

// MARK: Auth Controller V1 - Create Account
extension AuthController {
    
    // Step 1 - Check phone number availability.
    func checkPhoneNumberHandlerV1(_ req: Request) async throws -> Response<CheckPhoneNumberResponseV1> {
        guard let phoneNumber = req.parameters.get("phone_number") else {
            return Response(message: "Phone number parameter is missing.", code: .notFound)
        }
        
        let availability = try await checkPhoneNumberAvailabilityV1(phoneNumber: phoneNumber, req)
        
        return Response(result: CheckPhoneNumberResponseV1(status: availability),
                        message: availability.message(phoneNumber),
                        code: .ok)
    }
    
    // Auto - Check username availabiltiy.
    func autoCheckUsernameHandlerV1(_ req: Request) async throws -> Response<AutoCheckUsernameResponseV1> {
        guard let username = req.parameters.get("username") else {
           return Response(message: "Username parameter is missing.", code: .notFound)
        }
        
        let availability = try await checkUsernameAvailabilityV1(username: username, req)
        
        return Response(
            result: AutoCheckUsernameResponseV1(status: availability),
            message: availability.message(username),
            code: .ok
        )
    }
    
    // Step 2 - Check username availabiltiy and reserve username.
    func reserveUsernameHandlerV1(_ req: Request) async throws -> Response<ReserveUsernameResponseV1> {
        let payload = try req.content.decode(ResverUsernamePayloadV1.self)
        
        let availability = try await checkUsernameAvailabilityV1(username: payload.username, req)
        
        guard availability == .available else {
            return Response(result: ReserveUsernameResponseV1(status: .failure(availability)),
                            message: availability.message(payload.username),
                            code: .ok)
        }
        
        let reservedUsername = ReservedUsername(username: payload.username,
                                                clientID: payload.clientID,
                                                expiresAt: Date().addingTimeInterval(120))
        
        try await reservedUsername.create(on: req.db)
        
        return Response(result: ReserveUsernameResponseV1(status: .success),
                        message: "The \"\(payload.username)\" has been reserved.",
                        code: .ok)
    }
    
    // Step 3 - Send OTP code to phone number.
    func sendSMSOTPHandlerV1(_ req: Request) async throws -> Response<SendSMSOTPResponseV1> {
        let payload = try req.content.decode(SendSMSOTPPayloadV1.self)
        let phoneNumber = payload.phoneNumber
        let clientID = payload.clientID
        let type = payload.type
        
        let availability = try await checkPhoneNumberAvailabilityV1(phoneNumber: phoneNumber, req)
        
        guard availability == .available else {
            return Response(result: SendSMSOTPResponseV1(status: .failure(availability)),
                            message: availability.message(phoneNumber),
                            code: .ok)
        }
        
        let otpCode = String.randomDigits(ofLength: 6)
        
        _ = try await req.application.smsSender!
            .sendSMS(to: phoneNumber, message: type.message(code: otpCode), on: req.eventLoop)
        
        let expiryTime = Date().addingTimeInterval(60)
        
        let attempt = SMSVerificationAttempt(code: otpCode,
                                             phoneNumber: phoneNumber,
                                             clientID: clientID,
                                             expiresAt: expiryTime)
        
        try await attempt.create(on: req.db)
        
        let attemptID = try attempt.requireID()
        
        return Response(result: SendSMSOTPResponseV1(status: .sended(attemptID)),
                        message: "An OTP sms has been sent to the \"\(phoneNumber)\" phone number.",
                        code: .ok)
    }
    
    // Step 4 - Verify OTP and create account.
    func CreateAccountHandlerV1(_ req: Request) async throws -> Response<CreateAccountResponseV1> {
        let payload = try req.content.decode(CreateAccountPayloadV1.self)
        
        let otpResult = try await verifySMSV1(otp: payload.otp, req)
        
        switch otpResult {
            case .verified:
                let user: UserModel = try await req.db.transaction({ transaction in
                    let user = User()
                    try await user.create(on: transaction)
                    
                    let userID = try user.requireID()
                    
                    let phoneNumber = PhoneNumber(phoneNumber: payload.otp.phoneNumber, user: userID)
                    let username = Username(username: payload.username, user: userID)
                    
                    try await phoneNumber.create(on: transaction)
                    try await username.create(on: transaction)
                    
                    try await ReservedUsername.query(on: transaction)
                        .filter(\.$username == payload.username)
                        .delete(force: true)
                    
                    return try await user.convertToPulbic(transaction)
                })
                
                return Response(result: CreateAccountResponseV1(status: .success(user)),
                                message: "Account successfully created.",
                                code: .ok)
            case .expired:
                return Response(result: CreateAccountResponseV1(status: .failure(otpResult)),
                                message: "The OTP Code has expired.",
                                code: .ok)
            case .failure:
                return Response(result: CreateAccountResponseV1(status: .failure(otpResult)),
                                message: "Parameters are wrong. Phone number could not be verified.",
                                code: .notFound)
        }
    }
}
