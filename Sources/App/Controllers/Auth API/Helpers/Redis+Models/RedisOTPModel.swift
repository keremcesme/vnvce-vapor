//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Foundation
import Vapor

final class RedisOTPModel {
    struct V1: Content, Hashable {
        let encryptedCode: String
        let encrypedClientID: String
        
        let expireAt: TimeInterval
        let createdAt: TimeInterval
        
        init(
            encryptedCode: String,
            encrypedClientID: String
        ) {
            self.encryptedCode = encryptedCode
            self.encrypedClientID = encrypedClientID
            let date = Date()
            self.expireAt = date.addingTimeInterval(60).timeIntervalSince1970
            self.createdAt = date.timeIntervalSince1970
        }
        
        enum CodingKeys: String, CodingKey {
            case encryptedCode = "encrypted_code"
            case encrypedClientID = "encryped_client_id"
            case expireAt = "expire_at"
            case createdAt = "created_at"
        }
    }
}
