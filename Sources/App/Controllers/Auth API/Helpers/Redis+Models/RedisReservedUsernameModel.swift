//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Foundation
import Vapor

final class RedisReservedUsernameModel {
    struct V1: Content, Encodable {
        let clientID: String
        let userID: String?
        let exp: TimeInterval
        
        init(clientID: String, userID: String?) {
            self.clientID = clientID
            self.userID = userID
            self.exp = Date().addingTimeInterval(60).timeIntervalSince1970
        }
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
            case userID = "user_id"
            case exp
        }
    }
}
