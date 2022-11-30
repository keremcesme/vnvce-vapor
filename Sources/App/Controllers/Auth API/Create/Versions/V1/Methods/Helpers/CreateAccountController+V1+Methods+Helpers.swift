//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor
import Fluent
import Redis
import RediStack
import JWT

extension AuthController.CreateAccountController.V1 {
    
    
    
    public func checkPhoneNumberAvailability(
        phone: String,
        clientID: String, _ req: Request
    ) async throws -> PhoneNumberAvailability {
        let phoneQuery = try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phone)
            .first()
        
        guard phoneQuery == nil else {
            return .alreadyTaken
        }
        
        let key = RedisKey(phone)

        let otpAttemptQuery = try await req.redis.get(key, asJSON: RedisOTPModel.V1.self)
        
        if let otpAttempt = otpAttemptQuery {
//            if otpAttempt.clientID == clientID {
//                return .available
//            } else {
//                return .otpExist
//            }
        }
        return .available
    }
    
    public func checkUsernameAvailability(
        username: String,
        clientID: String,
        phoneNumber: String,
        _ req: Request
    ) async throws -> UsernameAvailability {
        let usernameQuery = try await Username.query(on: req.db)
            .filter(\.$username == username)
            .first()
        
        guard usernameQuery == nil else {
            return .alreadyTaken
        }
        
        let key = RedisKey("reserved_\(username)")
        
        let reservedUsernameQuery = try await req.redis.get(key, asJSON: RedisReservedUsernameModel.V1.self)
        
        if let reservedUsername = reservedUsernameQuery {
            if reservedUsername.clientID == clientID {
                return .userHasAlreadyReserved
            } else {
                return .reserved
            }
        }
        
        return .available
    }
    
}
