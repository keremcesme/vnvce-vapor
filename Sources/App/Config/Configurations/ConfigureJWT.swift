//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

fileprivate enum EnvironmentKey {
    static let `public` = Environment.get("RSA_PUBLIC_KEY")
    static let `private` = Environment.get("RSA_PRIVATE_KEY")
}

extension Application {
    public func configureJWT() async throws {
        self.logger.notice("[ 3/8 ] Configuring JWT")
        
        let privateKey = EnvironmentKey.private
        let publicKey = EnvironmentKey.public
        
        if privateKey == nil {
            let error = ConfigureError.missingRSAPrivateKey
            self.logger.notice(error.rawValue)
        }
        
        if publicKey == nil {
            let error = ConfigureError.missingRSAPublicKey
            self.logger.notice(error.rawValue)
        }
        
        if privateKey == nil || publicKey == nil {
            let error = ConfigureError.missingRSAKeys
            self.logger.notice(error.rawValue)
            throw error
        }
        
//        guard
//            let publicKey = EnvironmentKey.public,
//            let privateKey = EnvironmentKey.private
//        else {
//            let error = ConfigureError.missingRSAKeys
//            self.logger.notice(error.rawValue)
//            throw error
//        }
//        
//        let privateSigner = try JWTSigner.rs256(key: .private(pem: privateKey.bytes))
//        let publicSigner = try JWTSigner.rs256(key: .public(pem: publicKey.bytes))
//        
//        self.jwt.signers.use(privateSigner, kid: .private)
//        self.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
        
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
