//
//  File.swift
//  
//
//  Created by Kerem Cesme on 20.11.2022.
//

import Vapor
import Fluent
import Redis

struct RedisUserIDModel: Content, Encodable, Authenticatable {
    let userID: String
}

struct UserIDPayload: Content {
    let id: String
}

struct TokenAuthMiddleware: AsyncMiddleware {
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
//        guard let header = request.headers.bearerAuthorization?.token else {
//            print("NO AUTHORIZATION TOKEN IN HEADER")
//            return try await next.respond(to: request)
//        }
//        
//        guard let token = try await request.redis.get(RedisKey(header), asJSON: RedisUserIDModel.self) else {
//            print("NO TOKEN IN REDIS DB")
//            return try await next.respond(to: request)
//        }
//        
//        if token.token == header {
//            print("AUTHENTICATED")
//            request.auth.login(token)
//            
//            return try await next.respond(to: request)
//        } else {
//            
//            print("NOT AUTHENTICATED")
//            return try await next.respond(to: request)
//        }
        
        
        
        return try await next.respond(to: request)
    }
}
