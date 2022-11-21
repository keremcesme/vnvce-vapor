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
        apns.configuration = try .init(
            authenticationMethod: .jwt(
                key: .private(pem: Environment.get("APPLE_APN_PRIVATE_KEY") ?? ""),
                keyIdentifier: JWKIdentifier(string: Environment.get("APPLE_APN_KEY_ID") ?? ""),
                teamIdentifier: Environment.get("APPLE_TEAM_ID") ?? ""),
            topic: Environment.get("IOS_APP_BUNDLE_ID") ?? "",
            environment: .sandbox
        )
    }
}

