
import Foundation
import JWT

extension AppStoreNotificationPayload.NotificationData {
    public struct TransactionInfo: JWTPayload {
        let transactionId: String
        let bundleId: String
//        let environment: AppStoreNotificationPayload.Environment
        let expiresDate: UnixTimestamp?
        let inAppOwnershipType: OwnershipType
        let productId: String
        let purchaseDate: UnixTimestamp
        let quantity: Int
        let subscriptionGroupIdentifier: String?
        let type: ProductType
        let webOrderLineItemId: String?
        
        let appAccountToken: UUID?
        let isUpgraded: Bool
        
        let offerIdentifier: String?
        let offerType: Int?
        let originalPurchaseDate: UnixTimestamp?
        let revocationDate: UnixTimestamp?
        let signedDate: UnixTimestamp?
        
        public func verify(using signer: JWTSigner) throws {}
        
        public enum OwnershipType: String, Codable {
            case familyShared = "FAMILY_SHARED"
            case purchased = "PURCHASED"
        }
        
        public enum ProductType: String, Codable {
            case autoRenewable = "Auto-Renewable Subscription"
            case nonRenewing = "Non-Renewing Subscription"
            case nonConsumable = "Non-Consumable"
            case consumable = "Consumable"
        }
    }
}







