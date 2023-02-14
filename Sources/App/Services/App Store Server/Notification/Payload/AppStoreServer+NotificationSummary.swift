
import Foundation

extension AppStoreNotificationPayload {
    public struct NotificationSummary: Codable {
        let requestIdentifier: UUID
        let appAppleId: Int?
        let bundleId: String
        let productId: String
        let storefrontCountryCodes: [String]
        let failedCount: Int
        let succeededCount: Int
    }

}

