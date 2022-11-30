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
    
//    public func generateCreateAccountToken(_ req: Request, clientID: String) async throws -> String {
//        
//        let jwtPayload = CreateAccountJWTPayload(clientID)
//        let token = try req.jwt.sign(jwtPayload, kid: .private)
//        
//        let key = RedisKey("\(clientID):\(jwtPayload.jti.value)")
//        
//        try await req.redis.setex(key, toJSON: token, expirationInSeconds: 300)
//        
//        return token
//    }
}
