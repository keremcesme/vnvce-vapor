//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

extension Application {
    
    public func configureAppleDeviceCheck() throws {
        
        let privateKey = Environment.get("APPLE_DEVICE_CHECK_PRIVATE_KEY") ?? ""
        let signer = try JWTSigner.es256(key: .private(pem: privateKey.bytes))
        
        self.jwt.signers.use(signer, kid: .deviceCheckPrivate, isDefault: false)
    }
    
}
