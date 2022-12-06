
import Vapor
import SotoSNS

extension Application.AWS {
    public var sms: AWSConfiguration.SMS {
        .init(self.configuration)
    }
}

extension AWSConfiguration {
    public struct SMS {
        public let sns: SNS?
        public let messageAttributes: [String: SNS.MessageAttributeValue]?
        
        public init(_ config: AWSConfiguration?, senderID: String? = "vnvce") {
            if let config {
                self.sns = SNS(client: config.client, region: .eucentral1)
                self.messageAttributes = senderID.map { sender in
                    let senderAttribute = SNS.MessageAttributeValue(binaryValue: nil, dataType: "String", stringValue: sender)
                    return ["AWS.SNS.SMS.SenderID": senderAttribute]
                }
            } else {
                self.sns = nil
                self.messageAttributes = nil
            }
        }
        
        public func send(to phoneNumber: String, message: String) async throws {
            guard let sns else {
                throw Abort(.notFound)
            }
            
            let input = SNS.PublishInput(message: message,
                                         messageAttributes: messageAttributes,
                                         phoneNumber: phoneNumber)
            
            _ = try await sns.publish(input)
        }
    }
}
