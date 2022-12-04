
import Vapor

extension Application {
    public func configureAWSSMS() {
        
        self.logger.info("Setting AWS")
        
        let accessID = Environment.get("AWS_ACCESS_KEY_ID")
        let key = Environment.get("AWS_SECRET_ACCESS_KEY")
        let senderID = Environment.get("AWS_SNS_SENDER_ID")
        
        self.logger.info("Access Key ID: \(accessID ?? "nil")")
        self.logger.info("Access Secret Key: \(key ?? "nil")")
        self.logger.info("Sender ID: \(senderID ?? "nil")")
        
        self.sms.configuration = .init(
            accessKeyID: accessID!,
            secretAccessKey: key!,
            senderId: senderID!
        )
    }
}
    

//enum ConfigError: Error {
//    case missingAWSKeys
//}
//
//extension ConfigError: CustomDebugStringConvertible {
//    var debugDescription: String {
//        switch self {
//            case .missingAWSKeys: return "Missing AWS_KEY_ID or AWS_SECRET_KEY environment variables"
//        }
//    }
//}

//    public func configureAWS() throws {
//        guard
//            let accessKeyID = Environment.get("AWS_ACCESS_KEY_ID"),
//            let secretAccessKey = Environment.get("AWS_SECRET_ACCESS_KEY"),
//            let senderID = Environment.get("AWS_SNS_SENDER_ID")
//        else {
//            throw ConfigError.missingAWSKeys
//        }
//
//        let smsSender = AWSSNSSender(
//            accessKeyID: accessKeyID,
//            secretAccessKey: secretAccessKey,
//            senderId: senderID)
//
//        let s3 = AWSS3(accessKeyID: accessKeyID, secretAccessKey: secretAccessKey)
//
//        self.smsSender = smsSender
//        self.s3 = s3
//    }
