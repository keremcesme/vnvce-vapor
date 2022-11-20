//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import SotoSNS

func configureS3() throws -> AWSS3 {
    guard
        let accessKeyID = Environment.get("AWS_S3_ACCESS_KEY_ID"),
        let secretAccessKey = Environment.get("AWS_S3_SECRET_ACCESS_KEY")
    else {
        throw ConfigError.missingAWSKeys
    }
    
    let s3 = AWSS3(accessKeyID: accessKeyID, secretAccessKey: secretAccessKey)
    
    return s3
}

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
