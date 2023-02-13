
import Vapor
import JWT
import JWTKit

extension Application.AppStoreServer {
    public var notification: AppStoreServerConfiguration.Notification {
        .init(self.configuration)
    }
}

extension AppStoreServerConfiguration {
    public struct Notification {
        private let rootCert: String?
        
        public init(_ config: AppStoreServerConfiguration?) {
            if let config {
                self.rootCert = config.key
            } else {
                self.rootCert = nil
            }
        }
        
        public typealias NotificationPayload = AppStoreNotificationPayload
        
        public func verify(signed payload: String, _ req: Request) throws -> NotificationPayload {
            if let rootCert {
                let payload = try req.application.jwt.signers.verifyJWSWithX5C(payload, as: NotificationPayload.self, rootCert: rootCert)
                return payload
            } else {
                throw VerifyError.rootCertMissing
            }
        }
        
        public enum VerifyError: Error {
            case rootCertMissing
        }
        
    }
}
