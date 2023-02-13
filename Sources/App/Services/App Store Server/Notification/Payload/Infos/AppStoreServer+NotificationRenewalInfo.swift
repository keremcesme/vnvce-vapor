
import Foundation
import JWT

extension AppStoreNotificationPayload.NotificationData {
    public struct RenewalInfo: JWTPayload {
        let productId: String
        let autoRenewProductId: String
        let autoRenewStatus: Int
//        let environment: AppStoreEnvironment
        let signedDate: UnixTimestamp
        let recentSubscriptionStartDate: UnixTimestamp
        
        let expirationIntent: Int?
        let gracePeriodExpiresDate: UnixTimestamp?
        let isInBillingRetryPeriod: Bool?
        let offerIdentifier: String?
        let offerType: Int?
        let originalTransactionId: String?
        let priceIncreaseStatus: Int?
        
        public func verify(using signer: JWTSigner) throws {}
        
    }
}
    

