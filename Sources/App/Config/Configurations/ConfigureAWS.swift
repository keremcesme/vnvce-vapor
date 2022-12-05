
import Vapor

extension Application {
    public func configureAWSSMS() async throws {
        self.logger.notice("[ 4/8 ] Configuring AWS")
        
        let keyID = "AKIAQ3GKRZPZRBVUJR5X"
        let privateKey = "RKOCcxZqsWhAJnXKoh7sFatjoCOQCdduI/1rTTNa"
        let senderID = "vnvce"
        
//        guard
//            let keyID = Environment.get("AWS_ACCESS_KEY_ID"),
////            let privateKey = Environment.get("AWS_SECRET_ACCESS_KEY"),
//            let senderID = Environment.get("AWS_SNS_SENDER_ID")
//        else {
//            let error = ConfigureError.missingAWSEnvironments
//            self.logger.notice(error.rawValue)
//            throw error
//        }
        
        self.sms.configuration = .init(
            accessKeyID: keyID,
            secretAccessKey: privateKey,
            senderId: senderID
        )
        
        self.logger.notice("✅ AWS Configured")
    }
}



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
