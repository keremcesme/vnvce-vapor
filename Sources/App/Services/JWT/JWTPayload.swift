//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

struct MyJWTPayload: Authenticatable, JWTPayload {
    
    var id: UUID?
    var username: String
    var exp: ExpirationClaim
    
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
    
    
    
}
