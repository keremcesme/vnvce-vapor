//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Fluent
import Vapor
import Redis
import RediStack
import JWT

extension AuthController.CreateAccountController.V1 {
    
    public func checkPhoneNumber(_ req: Request)
    async throws -> AvailabilityResponse {
        let availability = try await checkPhoneNumberAvailability(req)
        var result: AvailabilityResponse
        
        switch availability {
        case .otpExist, .alreadyTaken:
            result = .init(.error)
        case .available:
            result = .init(.available)
        }
        
        result.message = availability.message
        
        return result
    }
    
    public func autoCheckUsernameHandler(_ req: Request)
    async throws -> AvailabilityResponse {
        let availability = try await checkUsernameAvailability(req)
        var result: AvailabilityResponse
        
        switch availability {
        case .reserved, .alreadyTaken:
            result = .init(.error)
        case .available:
            result = .init(.available)
        }
        
        result.message = availability.message
        
        return result
    }
    
    public func reserveUsernameAndSendOTPHandler(_ req: Request) async throws -> Response<String> {
        let p = try req.content.decode(ReserveUsernameAndSendOTPPayload.self)
        
        // first re-check username availability
//        try await req.redis.expire(key, after: .seconds(120))
        
        let key = RedisKey(p.username)
        
        try await req.redis.setex(key, toJSON: p.clientID, expirationInSeconds: 120)
        
        return Response(result: "", message: "")
    }
    
    public func verifyJWT(_ req: Request) async throws -> HTTPStatus {
        let jwt = try req.auth.require(CreateAccountJWTPayload.self)
        
        print("jasfhasuifhduk,ha,ukh")
        
//        let to = try req.auth.require(CreateAccountJWTPayload.self)
//        guard let token = req.headers.bearerAuthorization?.token else {
//            throw Abort(.badRequest)
//        }
////        let asdf = RedisOTPModel.V1(clientID: "asdfakl")
//        let jwt = try req.jwt.verify(token, as: CreateAccountJWTPayload.self)
//
        return .ok
    }
    
}
