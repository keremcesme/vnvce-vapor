//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor
import JWT

extension AuthController.CreateAccountController.V1 {
    struct CreateAccountJWTPayload: Authenticatable, JWTPayload, Content {
        var clientID: String
        var company: String
        
        var jti: IDClaim
        var iss: IssuerClaim
        var iat: IssuedAtClaim
        var exp: ExpirationClaim
        
        init(_ clientID: String) {
            let date = Date.now
            
            self.clientID = clientID
            self.company = "Socialayf"
            self.jti = .init(value: UUID().uuidString)
            self.iss = .init(value: "vnvce.com")
            self.iat = .init(value: date)
            self.exp = .init(value: date.addingTimeInterval(300))
        }
        
        func verify(using signer: JWTKit.JWTSigner) throws {
            try self.exp.verifyNotExpired()
        }
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
            case company
            case jti
            case iss
            case iat
            case exp
        }
    }
}
