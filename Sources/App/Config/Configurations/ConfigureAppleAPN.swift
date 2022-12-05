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

fileprivate enum EnvironmentKey {
    static let keyID = Environment.get("APPLE_APN_KEY_ID")
    static let privateKey = Environment.get("APPLE_APN_PRIVATE_KEY")
    static let teamID = Environment.get("APPLE_TEAM_ID")
    static let appBundleID = Environment.get("IOS_APP_BUNDLE_ID")
}

fileprivate typealias AuthMethod = APNSwiftConfiguration.AuthenticationMethod

extension Application {
    func configureAppleAPN() async throws {
        self.logger.notice("[ 5/8 ] Configuring Apple APNs")
        
        guard
            let keyID = EnvironmentKey.keyID,
            let privateKey = EnvironmentKey.privateKey,
            let teamID = EnvironmentKey.teamID,
            let appBundleID = EnvironmentKey.appBundleID
        else {
            let error = ConfigureError.missingAppleAPNSEnvironments
            self.logger.notice(error.rawValue)
            throw error
        }
        
        let authMethod: AuthMethod = try .jwt(
            key: .private(pem: privateKey),
            keyIdentifier: .init(string: keyID),
            teamIdentifier: teamID)
        
        let apnConfiguration = APNSwiftConfiguration(
            authenticationMethod: authMethod,
            topic: appBundleID,
            environment: .sandbox)
        
        apns.configuration = apnConfiguration
        
        self.logger.notice("✅ Apple APNs Configured")
    }
}

