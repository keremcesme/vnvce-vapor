//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import SNS

func configureSMSSender() throws -> AWSSNSSender {
    guard
        let accessKeyId = Environment.get("AWS_SNS_KEY_ID"),
        let secretKey = Environment.get("AWS_SNS_SECRET_KEY"),
        let senderID = Environment.get("AWS_SNS_SENDER_ID")
    else {
        throw ConfigError.missingAWSKeys
    }
    
    let snsSender = AWSSNSSender(accessKeyID: accessKeyId,
                                 secretAccessKey: secretKey,
                                 senderId: senderID)
    return snsSender
}

enum ConfigError: Error {
    case missingAWSKeys
}

extension ConfigError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
            case .missingAWSKeys: return "Missing AWS_KEY_ID or AWS_SECRET_KEY environment variables"
        }
    }
}
