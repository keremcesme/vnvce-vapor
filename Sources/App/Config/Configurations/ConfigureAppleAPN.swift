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
    
    private struct AppleAPNSCredentialsModel: Decodable {
        static let schema = "APPLE_APNS_CREDENTIALS"
        
        let keyID: String
        let key: String
        let teamID: String
        let iosAppBundleID: String
        
        enum CodingKeys: String, CodingKey {
            case keyID = "KEY_ID"
            case key = "KEY"
            case teamID = "TEAM_ID"
            case iosAppBundleID = "IOS_APP_BUNDLE_ID"
        }
    }
    
    func configureAppleAPN() async throws {
        self.logger.notice("[ 5/8 ] Configuring Apple APNs")
        
        let credentials = try await self.aws.secrets.getSecret(AppleAPNSCredentialsModel.schema, to: AppleAPNSCredentialsModel.self)
        
        let authMethod: AuthMethod = try .jwt(
            key: .private(pem: credentials.key.convertToKey),
            keyIdentifier: JWKIdentifier(string: credentials.keyID),
            teamIdentifier: credentials.teamID)
        
        let apnConfiguration = APNSwiftConfiguration(
            authenticationMethod: authMethod,
            topic: credentials.iosAppBundleID,
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
