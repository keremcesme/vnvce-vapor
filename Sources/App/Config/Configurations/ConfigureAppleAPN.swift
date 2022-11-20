//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import APNS
import JWT

extension Application {
    func configureAppleAPN() throws {
        let appleECP8PrivateKey =
        """
        -----BEGIN PRIVATE KEY-----
        MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgr5fwKbqdYeGQN/GK
        bDuW1SAGXukW5juL6UVsVWLE1YugCgYIKoZIzj0DAQehRANCAASNAG97eVxBKSZr
        SvNE9jGrR+P9ThOBQQN+a1SWOEMHrjzbBLjLgQU8AEAt2onve10IEGqD7su/dIEt
        xJsDxiGt
        -----END PRIVATE KEY-----
        """
        
        apns.configuration = try .init(
            authenticationMethod: .jwt(
                key: .private(pem: appleECP8PrivateKey),
                keyIdentifier: JWKIdentifier(string: Environment.get("APPLE_APN_KEY_ID") ?? ""),
                teamIdentifier: Environment.get("APPLE_TEAM_ID") ?? ""),
            topic: Environment.get("IOS_APP_BUNDLE_ID") ?? "",
            environment: .sandbox
        )
    }
}

