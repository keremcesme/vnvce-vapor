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
        guard
            let phoneNumber = req.parameters.get("phone_number"),
            let clientIDString = req.parameters.get("client_id"),
            let clientID = UUID(uuidString: clientIDString)
        else {
            return Response(message: "Phone number parameter is missing.", code: .notFound)
        }
        
        let availability = try await checkPhoneNumberAvailabilityV1(
            phoneNumber: phoneNumber,
            clientID: clientID,
            req)
        
        return Response(result: CheckPhoneNumberResponseV1(status: availability.0),
                        message: availability.0.message(phoneNumber),
                        code: .ok)
    }
    
    // Auto - Check username availabiltiy.
    func autoCheckUsernameHandlerV1(_ req: Request) async throws -> Response<AutoCheckUsernameResponseV1> {
        guard
            let username = req.parameters.get("username"),
            let clientIDString = req.parameters.get("client_id"),
            let clientID = UUID(uuidString: clientIDString)
        else {
            return Response(message: "`username` or `client_id` parameter is missing.", code: .notFound)
        }
        
        let availability = try await checkUsernameAvailabilityV1(
            username: username,
            clientID: clientID,
            req)
        
        return Response(
            result: AutoCheckUsernameResponseV1(status: availability),
            message: availability.message(username),
            code: .ok
        )
    }
    
    // Step 2 - Reserve Username and Send OTP code to phone number.
    func reserveUsernameAndSendSMSOTPHandlerV1(_ req: Request) async throws -> Response<ReserveUsernameAndSendSMSOTPResponseV1> {
        let payload = try req.content.decode(ReserveUsernameAndSendSMSOTPPayloadV1.self)
        let username = payload.username
        let phoneNumber = payload.phoneNumber
        let clientID = payload.clientID
        let type = payload.type
        
        let reserve = try await reserveUsernameV1(
            username: username,
            clientID: clientID,
            req)
        
        switch reserve {
            case let .failure(failure):
                let result = ReserveUsernameAndSendSMSOTPResponseV1(status: .failure(.username(failure)))
                return Response(
                    result: result,
                    message: "ok",
                    code: .ok)
                
            case .success:
                let sms = try await sendSMSOTPV1(
                    phoneNumber: phoneNumber,
                    clientID: clientID,
                    type: type,
                    req)
                
                switch sms {
                    case let .failure(failure):
                        let result = ReserveUsernameAndSendSMSOTPResponseV1(status: .failure(.phone(failure)))
                        
                        return Response(
                            result: result,
                            message: "ok",
                            code: .ok)
                        
                    case let .success(success):
                        let result = ReserveUsernameAndSendSMSOTPResponseV1(status: .success(success))
                        
                        return Response(
                            result: result,
                            message: "ok",
                            code: .ok)
                }
                
        }
    }
    
    func resendSMSOTPHandlerV1(_ req: Request) async throws -> Response<ResendSMSOTPResponseV1> {
        
        let payload = try req.content.decode(ResendSMSOTPPayloadV1.self)
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
        
        let response = ResendSMSOTPResponseV1(status: SendSMSOTPAttempt(
            attemptID: attemptID,
            startTime: startTime,
            expiryTime: expiryTime.timeIntervalSince1970))
        return Response(
            result: response,
            message: "",
            code: .ok)
    }
    
    // Step 3 - Verify OTP and create account.
    func createAccountHandlerV1(_ req: Request) async throws -> Response<CreateAccountResponseV1> {
        let payload = try req.content.decode(CreateAccountPayloadV1.self)
        
        let otpResult = try await verifySMSV1(otp: payload.otp, req)
        
        switch otpResult {
            case .verified:
                let success = try await createUserV1(username: payload.username, otp: payload.otp, req)
                return Response(
                    result: CreateAccountResponseV1(
                        status: .success(success)
                    ),
                    message: "Account successfully created.",
                    code: .ok
                )
            case .expired:
                return Response(
                    result: CreateAccountResponseV1(
                        status: .failure(otpResult)
                    ),
                    message: "The OTP code has expired.",
                    code: .ok
                )
            case .failure:
                return Response(
                    result: CreateAccountResponseV1(
                        status: .failure(otpResult)
                    ),
                    message: "Parameters are wrong. Phone number could not be verified.",
                    code: .notFound)
        }
    }
    
    // MARK: Optional Steps
    // Step 4 - Set Profile Picture.
    func profilePictureHandlerV1(_ req: Request) async throws -> HTTPStatus{
        let user = try req.auth.require(User.self)
        let payload = try req.content.decode(ProfilePicturePayloadV1.self)
        let userID = try user.requireID()
        let url = payload.url
        let name = payload.name
        
        let profilePicture = ProfilePicture(userID: userID, url: url, name: name)
        
        try await profilePicture.create(on: req.db)
        
        return .ok
    }
    
    // Step 5 - Set Display Name.
    func displayNameHandlerV1(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard let displayName = req.parameters.get("display_name") else {
            return .notFound
        }
        
        user.displayName = displayName
        
        try await user.update(on: req.db)
        
        return .ok
    }
    
    // Step 6 - Set Biography.
    func biographyHandlerV1(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        guard let biography = req.parameters.get("biography") else {
            return .notFound
        }
        
        user.biography = biography
        
        try await user.update(on: req.db)
        
        return .ok
    }
    
}
