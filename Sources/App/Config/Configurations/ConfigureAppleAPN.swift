//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import APNS
import APNSwift
import JWT

fileprivate typealias AuthMethod = APNSwiftConfiguration.AuthenticationMethod

extension Application {
    func configureAppleAPN() async throws {
        self.logger.notice("[ 3/8 ] Configuring Apple APNs")
        
        guard
            let keyID = Environment.get("APPLE_APN_KEY_ID"),
            let privateKey = Environment.get("APPLE_APN_PRIVATE_KEY"),
            let teamID = Environment.get("APPLE_TEAM_ID"),
            let appBundleID = Environment.get("IOS_APP_BUNDLE_ID")
        else {
            let error = ConfigureError.missingAppleAPNSEnvironments
            self.logger.notice(error.rawValue)
            throw error
        }
        
        let authMethod: AuthMethod = try .jwt(
            key: .private(pem: privateKey),
            keyIdentifier: JWKIdentifier(string: keyID),
            teamIdentifier: teamID)
        
        let apnConfiguration = APNSwiftConfiguration(
            authenticationMethod: authMethod,
            topic: appBundleID,
            environment: .sandbox)
        
        apns.configuration = apnConfiguration
        
        self.logger.notice("✅ Apple APNs Configured")
    }
}

//apns.configuration = try .init(
//    authenticationMethod: .jwt(
//        key: .private(pem: Environment.get("APPLE_APN_PRIVATE_KEY") ?? ""),
//        keyIdentifier: JWKIdentifier(string: Environment.get("APPLE_APN_KEY_ID") ?? ""),
//        teamIdentifier: Environment.get("APPLE_TEAM_ID") ?? ""),
//    topic: Environment.get("IOS_APP_BUNDLE_ID") ?? "",
//    environment: .sandbox
//)
