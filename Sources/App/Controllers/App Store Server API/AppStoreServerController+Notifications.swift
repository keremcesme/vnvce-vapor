
import Vapor
import Fluent
import JWT
import JWTKit

extension AppStoreServerController {
    private struct SignedPayload: Decodable {
        let signedPayload: String
    }
    
    public func notificationsHandler(_ req: Request) async throws -> HTTPStatus {
        let rootCert = req.application.appStoreServer.configuration!.key
        let notification = try req.content.decode(SignedPayload.self)
        
        let payload = try req.application.jwt.signers.verifyJWSWithX5C(
            notification.signedPayload,
            as: NotificationPayload.self,
            rootCert: rootCert)
        
        print("Notification ID: \(payload.notificationUUID)")
        print("Notification Type: \(payload.notificationType.rawValue)")
        print("Notification Sub Type: \(payload.subtype?.rawValue ?? "NULL")")
//        print("App Apple ID: \(String(describing: payload.data.appAppleId))")
//        print("Bundle ID: \(payload.data.bundleId)")
//        print("Bundle Version: \(payload.data.bundleVersion)")
//        print("Environment: \(payload.data.environment.rawValue)")
        
        if let signedRenewalInfo = payload.data.signedRenewalInfo {
            let renewalInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                signedRenewalInfo,
                as: NotificationRenewalInfo.self,
                rootCert: rootCert)
//            print("Renewal Info:")
//            print("Product ID: \(renewalInfo.productId)")
//            print("Auto Renew Product ID: \(renewalInfo.autoRenewProductId)")
            print("Original Transaction ID: \(renewalInfo.originalTransactionId ?? "NULL")")
        }
        
        if let signedTransactionInfo = payload.data.signedTransactionInfo {
            let transactionInfo = try req.application.jwt.signers.verifyJWSWithX5C(
                signedTransactionInfo,
                as: NotificationTransactionInfo.self,
                rootCert: rootCert)
            print("Transaction ID: \(transactionInfo.transactionId)")
            print("Time: \(transactionInfo.purchaseDate.date)")
            print("Expire or Renew: \(transactionInfo.expiresDate.date)")
//            print("Ownership: \(transactionInfo.inAppOwnershipType.rawValue)")
//            print("Product ID: \(transactionInfo.productId)")
//            print("Group Identifier: \(transactionInfo.subscriptionGroupIdentifier)")
//            print("Type: \(transactionInfo.type.rawValue)")
//            print("User ID: \(String(describing: transactionInfo.appAccountToken))")
//            print("Is Upgraded: \(String(describing: transactionInfo.isUpgraded))")
        }
        
        print("------------------------------------------------------------------------------------")
        
        return .ok
    }
    
    
}
