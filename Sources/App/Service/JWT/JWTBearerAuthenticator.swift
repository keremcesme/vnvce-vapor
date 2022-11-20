//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

struct JWTBearerAuthenticator: AsyncJWTAuthenticator {
    typealias Payload = MyJWTPayload
    
    func authenticate(jwt: Payload, for request: Request) async throws {
        
        try jwt.verify(using: request.application.jwt.signers.get()!)
        
        guard let user = try await User.find(jwt.id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        return request.auth.login(user)
    }
    
}

struct JWTUserModelBearerAuthenticator: AsyncBearerAuthenticator {
    
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        
        let jwt = try request.jwt.verify(bearer.token, as: MyJWTPayload.self)
        
        guard let user = try await User.find(jwt.id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        return request.auth.login(user)
    }
    
    
    
    
}
