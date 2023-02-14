
import Vapor
import JWT
import JWTKit

extension Application.AppStoreServer {
    public var notification: AppStoreServerConfiguration.Notification {
        .init(self.configuration)
    }
}

public protocol AppStoreServerNotification {
    typealias NotificationPayload = AppStoreNotificationPayload
    typealias NotificationData = NotificationPayload.NotificationData
    typealias TransactionInfo = NotificationData.TransactionInfo
    typealias RenewalInfo = NotificationData.RenewalInfo
    typealias TransactionAndRenewalInfo = (transactionInfo: TransactionInfo?, renewalInfo: RenewalInfo?)
    typealias NotificationPayloadAll = (payload: NotificationPayload, transactionInfo: TransactionInfo?, renewalInfo: RenewalInfo?)
}

public protocol AppStoreServerNotificationVerify: AppStoreServerNotification {
    func verify(_ signedNotification: String, on req: Request) throws -> NotificationPayload
    func verifyAll(_ signedNotification: String, on req: Request) throws -> NotificationPayloadAll
    func verifyTransaction(_ signedTransactionInfo: String, on req: Request) throws -> TransactionInfo
    func verifyTransaction(_ data: NotificationData, on req: Request) throws -> TransactionInfo?
    func verifyRenewal(_ signedRenewalInfo: String, on req: Request) throws -> RenewalInfo
    func verifyRenewal(_ data: NotificationData, on req: Request) throws -> RenewalInfo?
    func verifyTransactionAndRenewal(_ data: NotificationData, on req: Request) throws -> TransactionAndRenewalInfo
}

extension AppStoreServerConfiguration {
    public struct Notification: AppStoreServerNotificationVerify {
        private let rootCert: String?
        
        public init(_ config: AppStoreServerConfiguration?) {
            if let config {
                self.rootCert = config.key
            } else {
                self.rootCert = nil
            }
        }
        
        /// To verify notification payload.
        public func verify(_ signedNotification: String, on req: Request) throws -> NotificationPayload {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            let payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedNotification,
                as: NotificationPayload.self,
                rootCert: rootCert)
            return payload
        }
        
        /// To verify notification payload with `Transaction Info` and `Renewal Info`.
        public func verifyAll(_ signedNotification: String, on req: Request) throws -> NotificationPayloadAll {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            var payload: NotificationPayload
            var transaction: TransactionInfo? = nil
            var renwal: RenewalInfo? = nil
            
            payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedNotification,
                as: NotificationPayload.self,
                rootCert: rootCert)
            
            if let signedTransactionInfo = payload.data.signedTransactionInfo {
                let transactionInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                    signedTransactionInfo,
                    as: TransactionInfo.self,
                    rootCert: rootCert)
                transaction = transactionInfo
            }
            
            if let signedRenewalInfo = payload.data.signedRenewalInfo {
                let renewalInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                    signedRenewalInfo,
                    as: RenewalInfo.self,
                    rootCert: rootCert)
                renwal = renewalInfo
            }
            
            return (payload, transaction, renwal)
        }
        
        /// Validates the `Transaction Info` value in the notification payload.
        public func verifyTransaction(_ signedTransactionInfo: String, on req: Request) throws -> TransactionInfo {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            let payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedTransactionInfo,
                as: TransactionInfo.self,
                rootCert: rootCert)
            
            return payload
        }
        
        /// Validates the `Transaction Info` value in the notification payload.
        public func verifyTransaction(_ data: NotificationData, on req: Request) throws -> TransactionInfo? {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            guard let signedTransactionInfo = data.signedTransactionInfo else {
                return nil
            }
            
            let payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedTransactionInfo,
                as: TransactionInfo.self,
                rootCert: rootCert)
            
            return payload
        }
        
        /// Validates the `Renewal Info` value in the notification payload.
        public func verifyRenewal(_ signedRenewalInfo: String, on req: Request) throws -> RenewalInfo {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            let payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedRenewalInfo,
                as: RenewalInfo.self,
                rootCert: rootCert)
            
            return payload
        }
        
        /// Validates the `Renewal Info` value in the notification payload.
        public func verifyRenewal(_ data: NotificationData, on req: Request) throws -> RenewalInfo? {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            guard let signedRenewalInfo = data.signedRenewalInfo else {
                return nil
            }
            
            let payload = try req.application.jwt.signers.verifyJWSWithX5C(
                signedRenewalInfo,
                as: RenewalInfo.self,
                rootCert: rootCert)
            
            return payload
        }
        
        /// Verifies the `Transaction Info` and `Renewal Info` values in the notification payload.
        public func verifyTransactionAndRenewal(_ data: NotificationData, on req: Request) throws -> TransactionAndRenewalInfo {
            guard let rootCert else {
                throw VerifyError.rootCertMissing
            }
            
            var transaction: TransactionInfo? = nil
            var renwal: RenewalInfo? = nil
            
            if let signedTransactionInfo = data.signedTransactionInfo {
                let transactionInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                    signedTransactionInfo,
                    as: TransactionInfo.self,
                    rootCert: rootCert)
                transaction = transactionInfo
            }
            
            if let signedRenewalInfo = data.signedRenewalInfo {
                let renewalInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                    signedRenewalInfo,
                    as: RenewalInfo.self,
                    rootCert: rootCert)
                renwal = renewalInfo
            }
            
            return (transaction, renwal)
        }
        
        public enum VerifyError: Error {
            case rootCertMissing
        }
        
    }
}
