//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor
import JWT
import Redis
import RediStack

extension AuthController.CreateAccountController.V1 {
    
    final class CreateAccountMiddleware: AsyncMiddleware {
        func respond(
            to request: Request,
            chainingTo next: AsyncResponder
        ) async throws -> Vapor.Response {
            if let token = request.headers.bearerAuthorization?.token {
                let auth = CreateAccountJWTPayload.self
                do {
                    let jwtPayload = try request.jwt.verify(
                        token,
                        as: auth)
                    
                    let clientID = jwtPayload.clientID
                    let jti = jwtPayload.jti.value
                    
                    let key = RedisKey("\(clientID):\(jti)")
                    
                    if try await request.redis.exists(key).get() != 0 {
                        request.auth.login(jwtPayload)
                    }
                    
                    return try await next.respond(to: request)
                } catch {
                    return try await next.respond(to: request)
                }
            } else {
                return try await next.respond(to: request)
            }
            
        }
    }
    
}

final class CreateAccountMiddleware: AsyncMiddleware {
    
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
        
        if let token = request.headers.bearerAuthorization?.token {
            
        } else {
            
            
        }
        
        return try await next.respond(to: request)
    }
}
