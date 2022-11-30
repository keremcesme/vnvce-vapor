//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor
import JWT

extension AuthController.CreateAccountController.V1 {
    struct OTPJWTPayload: Authenticatable, JWTPayload, Content {
        var clientID: String
        var company: String
        var encryptedPhoneNumber: String
        
        var jti: IDClaim
        var iss: IssuerClaim
        var iat: IssuedAtClaim
        var exp: ExpirationClaim
        
        init(_ clientID: String, encryptedPhoneNumber: String, jti: String, date: Date, second: TimeInterval) {
            self.clientID = clientID
            self.encryptedPhoneNumber = encryptedPhoneNumber
            
            self.company = "Socialayf"
            self.jti = .init(value: jti)
            self.iss = .init(value: "vnvce.com")
            self.iat = .init(value: date)
            self.exp = .init(value: date.addingTimeInterval(second))
        }
        
        func verify(using signer: JWTKit.JWTSigner) throws {
            try self.exp.verifyNotExpired()
        }
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
            case encryptedPhoneNumber = "encryptes_phone_number"
            case company
            case jti
            case iss
            case iat
            case exp
        }
    }
}
