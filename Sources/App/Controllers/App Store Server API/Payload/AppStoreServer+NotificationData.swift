
import Foundation

extension AppStoreServerController {
    public struct NotificationData: Codable {
        // App Store'daki bir uygulamanın benzersiz tanımlayıcısı.
        let appAppleId: Int?
        // Uygulamanın paket tanımlayıcısı.
        let bundleId: String
        // Paketin bir yinelemesini tanımlayan yapı sürümü.
        let bundleVersion: String
        // Bildirimin geçerli olduğu sunucu ortamı, sanbox veya production.
        let environment: Environment
        // App Store tarafından JWS biçiminde imzalanmış abonelik yenileme bilgileri.
        let signedRenewalInfo: String?
        // App Store tarafından JWS biçiminde imzalanmış işlem bilgileri.
        let signedTransactionInfo: String?
    }
    
    public enum Environment: String, Codable {
        case sandbox = "Sandbox"
        case production = "Production"
    }
}
