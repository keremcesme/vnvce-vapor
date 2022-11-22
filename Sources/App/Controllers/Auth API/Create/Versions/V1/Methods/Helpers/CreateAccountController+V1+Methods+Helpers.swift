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
    
    public func checkPhoneNumberAvailability(_ req: Request) async throws -> PhoneNumberAvailability{
        let p = try req.content.decode(CheckPhonePayload.self)
        let phone = p.phoneNumber
        let clientID = p.clientID
        
        let phoneQuery = try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phone)
            .first()
        
        guard phoneQuery == nil else {
            return .alreadyTaken
        }
        
        let key = RedisKey(phone)

        let otpAttemptQuery = try await req.redis.get(key, asJSON: RedisOTPModel.V1.self)
        
        if let otpAttempt = otpAttemptQuery {
            if otpAttempt.clientID == clientID {
                return .available
            } else {
                return .otpExist
            }
        }
        return .available
    }
    
    public func checkUsernameAvailability(_ req: Request) async throws -> UsernameAvailability {
        let p = try req.content.decode(CheckUsernamePayload.self)
        let username = p.username
        let clientID = p.clientID
        
        let usernameQuery = try await Username.query(on: req.db)
            .filter(\.$username == username)
            .first()
        
        guard usernameQuery == nil else {
            return .alreadyTaken
        }
        
        let key = RedisKey(username)
        
        let reservedUsernameQuery = try await req.redis.get(key, asJSON: String.self)
        
        if let value = reservedUsernameQuery {
            if value == clientID {
                return .available
            } else {
                return .reserved
            }
        }
        return .available
        
    }
    
}
