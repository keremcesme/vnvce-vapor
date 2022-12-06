
import Vapor

extension Application {
    public func configureAWS() async throws {
        self.logger.notice("[ 1/8 ] Configuring AWS")
        
        guard
            let keyID = Environment.get("AWS_KEY_ID"),
            let privateKey = Environment.get("AWS_KEY")
        else {
            let error = ConfigureError.missingAWSEnvironments
            self.logger.notice(error.rawValue)
            throw error
        }
        
        self.aws.configuration = .init(keyID: keyID, key: privateKey)
        
        self.logger.notice("✅ AWS Configured")
    }
}
