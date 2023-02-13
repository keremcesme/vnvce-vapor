
import Foundation
import JWT
import JWTKit

extension AppStoreServerController {
    public struct NotificationRenewalInfo: JWTPayload {
        let productId: String
        let autoRenewProductId: String
        let autoRenewStatus: Int
        let environment: Environment
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
