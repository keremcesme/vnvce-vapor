//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import SNS

class AWSSNSSender {
    private let sns: SNS
    private let messageAttributes: [String: SNS.MessageAttributeValue]?
    
    init(accessKeyID: String, secretAccessKey: String, senderId: String?) {
        sns = SNS(accessKeyId: accessKeyID, secretAccessKey: secretAccessKey, region: .eucentral1)
        
        messageAttributes = senderId.map { sender in
            let senderAttribute = SNS.MessageAttributeValue(binaryValue: nil,
                                                            dataType: "String",
                                                            stringValue: sender)
            return ["AWS.SNS.SMS.SenderID": senderAttribute]
        }
    }
}

extension AWSSNSSender: SMSSender {
    func sendSMS(to phoneNumber: String, message: String, on eventLoop: EventLoop) async throws -> EventLoopFuture<Bool> {
        let input = SNS.PublishInput(message: message,
                                     messageAttributes: messageAttributes,
                                     phoneNumber: phoneNumber)
        
        return sns.publish(input).hop(to: eventLoop).map { $0.messageId != nil }
    }
}

