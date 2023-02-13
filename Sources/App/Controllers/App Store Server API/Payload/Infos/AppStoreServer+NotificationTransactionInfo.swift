
import Foundation
import JWT
import JWTKit


extension AppStoreServerController {
    public struct NotificationTransactionInfo: JWTPayload {
        let transactionId: String
        let bundleId: String
        let environment: Environment
        let expiresDate: UnixTimestamp?
        let inAppOwnershipType: AppOwnershipType
        let productId: String
        let purchaseDate: UnixTimestamp
        let quantity: Int
        let subscriptionGroupIdentifier: String?
        let type: PurchaseType
        let webOrderLineItemId: String?
        
        let appAccountToken: UUID?
        let isUpgraded: Bool
        
        let offerIdentifier: String?
        let offerType: Int?
        let originalPurchaseDate: UnixTimestamp?
        let revocationDate: UnixTimestamp?
        let signedDate: UnixTimestamp?
        
        public func verify(using signer: JWTSigner) throws {}
    }
    
    public enum AppOwnershipType: String, Codable {
        case familyShared = "FAMILY_SHARED"
        case purchased = "PURCHASED"
    }
    
    public enum PurchaseType: String, Codable {
        case autoRenewable = "Auto-Renewable Subscription"
        case nonRenewing = "Non-Renewing Subscription"
        case nonConsumable = "Non-Consumable"
        case consumable = "Consumable"
        
    }
}

