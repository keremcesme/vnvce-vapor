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
        let privateKey = try String(contentsOfFile: self.directory.workingDirectory + "Security/jwtRS256.key")
        let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
        
        let publicKey = try String(contentsOfFile: self.directory.workingDirectory + "Security/jwtRS256.key.pub")
        let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))
        
        self.jwt.signers.use(privateSigner, kid: .private)
        self.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
    }
}
