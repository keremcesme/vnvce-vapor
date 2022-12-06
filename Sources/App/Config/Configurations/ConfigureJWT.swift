//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

extension Application {
    public func configureJWT() async throws {
        self.logger.notice("[ 5/8 ] Configuring JWT")
        
//        print(Environment.get("RSA_PRIVATE_KEY"))
//        print(Environment.get("RSA_PUBLIC_KEY"))
        
        do {
            guard
                let privateKey = Environment.get("RSA_PRIVATE_KEY")?.key,
                let publicKey = Environment.get("RSA_PUBLIC_KEY")?.key
            else {
                let error = ConfigureError.missingRSAKeys
                self.logger.notice(error.rawValue)
                throw error
            }
            
//            let privateKey = String(privateKeyRaw).key
//            let publicKey = String(publicKeyRaw).key
            
            self.logger.notice("Public Key: \(publicKey)")
            self.logger.notice("Private Key: \(privateKey)")
            
            let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
            let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))

            self.jwt.signers.use(privateSigner, kid: .private)
            self.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        self.logger.notice("✅ JWT Configured")
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
