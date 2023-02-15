
import Foundation
import JWT

extension AppStoreNotificationPayload.NotificationData {
    public struct RenewalInfo: JWTPayload {
        let autoRenewProductId: String?
        let autoRenewStatus: Int?
        let expirationIntent: Int?
        let gracePeriodExpiresDate: UnixTimestamp?
        let isInBillingRetryPeriod: Bool?
        let offerIdentifier: String?
        let offerType: Int?
        let originalTransactionId: String?
        let priceIncreaseStatus: Int?
        let recentSubscriptionStartDate: UnixTimestamp?
        
        public func verify(using signer: JWTSigner) throws {}
        
    }
}


