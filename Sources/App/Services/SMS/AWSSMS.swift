//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor
import SotoSNS

extension Application {
    public var sms: SMS {
        .init(application: self)
    }
    
    public struct SMS {
        let application: Application
        
        struct ConfigurationKey: StorageKey {
            typealias Value = AWSSMSConfiguration
        }
        
        public var configuration: AWSSMSConfiguration? {
            get {
                self.application.storage[ConfigurationKey.self]
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
        
        func send(to phoneNumber: String, message: String) async throws {
            guard let config = configuration else {
                throw Abort(.notFound)
            }
            
            let input = SNS.PublishInput(message: message,
                                         messageAttributes: config.messageAttributes,
                                         phoneNumber: phoneNumber)
            
            let result = try await config.sns.publish(input)
            
        }
        
    }
}

public struct AWSSMSConfiguration {
    public let sns: SNS
    public let messageAttributes: [String: SNS.MessageAttributeValue]?
    
    init(accessKeyID: String, secretAccessKey: String, senderId: String?) {
        let client = AWSClient(
            credentialProvider: .static(
                accessKeyId: accessKeyID,
                secretAccessKey: secretAccessKey),
            httpClientProvider: .createNew)
        
        self.sns = SNS(client: client, region: .eucentral1)
        self.messageAttributes = senderId.map { sender in
            let senderAttribute = SNS.MessageAttributeValue(binaryValue: nil,
                                                            dataType: "String",
                                                            stringValue: sender)
            return ["AWS.SNS.SMS.SenderID": senderAttribute]
        }
        
    }
}
