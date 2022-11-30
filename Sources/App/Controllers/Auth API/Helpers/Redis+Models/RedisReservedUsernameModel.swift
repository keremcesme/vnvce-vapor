//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Foundation
import Vapor

struct RedisReservedUsernameModel {
    struct V1: Content, Encodable {
        let clientID: String
        
        init(clientID: String) {
            self.clientID = clientID
        }
        
        enum CodingKeys: String, CodingKey {
            case clientID = "client_id"
        }
    }
}
