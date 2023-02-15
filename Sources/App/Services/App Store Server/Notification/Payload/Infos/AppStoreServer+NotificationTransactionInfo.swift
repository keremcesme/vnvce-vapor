
import Foundation
import JWT
import VNVCECore

extension AppStoreNotificationPayload.NotificationData {
    public struct TransactionInfo: JWTPayload {
        let transactionId: String
        let originalTransactionId: String?
        let appAccountToken: UUID
        let webOrderLineItemId: String?
        let subscriptionGroupIdentifier: String?
        let productId: String
        let type: ProductType
        let isUpgraded: Bool?
        let inAppOwnershipType: OwnershipType
        let quantity: Int
        let offerIdentifier: String?
        let offerType: Int?
        let revocationReason: Int?
        let purchaseDate: UnixTimestamp
        let originalPurchaseDate: UnixTimestamp?
        let expiresDate: UnixTimestamp?
        let revocationDate: UnixTimestamp?
        let signedDate: UnixTimestamp
        
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

extension AppStoreNotificationPayload.NotificationData.TransactionInfo.ProductType {
    var convert: AppStoreProductType {
        switch self {
        case .autoRenewable:
            return .autoRenewable
        case .nonRenewing:
            return .nonRenewing
        case .nonConsumable:
            return .nonConsumable
        case .consumable:
            return .consumable
        }
    }
}

extension AppStoreNotificationPayload.NotificationData.TransactionInfo.OwnershipType {
    var convert: AppStoreProductOwnershipType {
        switch self {
        case .familyShared:
            return .familyShared
        case .purchased:
            return .purchased
        }
    }
}

extension Int {
    var convertOfferType: AppStoreOfferType? {
        switch self {
        case 1:
            return .introductory
        case 2:
            return .promotional
        case 3:
            return .code
        default:
            return nil
        }
    }
}

extension Int {
    var convertRevocationReason: AppStoreRevocationReason? {
        switch self {
        case 0:
            return .other
        case 1:
            return .developerIssue
        default:
            return nil
        }
    }
}
