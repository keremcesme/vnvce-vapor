//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

extension Application {
    public func configureJWT() throws {
        
        let privateKey = try getPrivateKEY()
        let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
        
        let publicKey = try getPublicKEY()
        let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))
        
        self.jwt.signers.use(privateSigner, kid: .private)
        self.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
    }
    
    private func getPrivateKEY() throws -> String {
        
        if let envKey = Environment.get("RSA_PRIVATE_KEY") {
            return envKey
        } else {
            return try String(contentsOfFile: self.directory.workingDirectory + "Credentials/jwtRS256.key")
        }
        
    }
    
    private func getPublicKEY() throws -> String {
        if let envKey = Environment.get("RSA_PUBLIC_KEY") {
            return envKey
        } else {
            return try String(contentsOfFile: self.directory.workingDirectory + "Credentials/jwtRS256.key.pub")
        }
        
    }
    
}
