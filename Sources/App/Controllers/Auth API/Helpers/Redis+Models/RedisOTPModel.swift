//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Foundation
import Vapor

final class RedisOTPModel {
    struct V1: Content, Encodable {
        let otp: Int
        let phoneNumber: String
        let clientID: String
        let userID: String?
        let jti: String
        let exp: TimeInterval
        
        init(otp: Int, phoneNumber: String, clientID: String, userID: String? = nil, jti: String) {
            self.otp = otp
            self.phoneNumber = phoneNumber
            self.clientID = clientID
            self.userID = userID
            self.jti = jti
            self.exp = Date().addingTimeInterval(60).timeIntervalSince1970
        }
        
        enum CodingKeys: String, CodingKey {
            case otp
            case phoneNumber = "phone_number"
            case clientID = "client_id"
            case userID = "user_id"
            case jti
            case exp
        }
    }
}
