
import Foundation
import JWT

public struct AppStoreNotificationPayload: JWTPayload {
    // Uygulama içi satın alma olayı.
    let notificationType: NotificationType
    
    // Uygulama içi satın alma olayının ayrıntıları. (varsa)
    let subtype: NotificationSubtype?
    
    // Benzersiz ID
    let notificationUUID: String
    
    // Uygulama meta verileri ve imzalı yenileme ve işlem bilgileri.
    let data: NotificationData
    
    /// Summary nesnesi, yalnızca bildirim `SUMMARY` subtype'a sahip bir `RENEWAL_EXTENDED` olduğunda bilgi içerir.
    let summary: NotificationSummary?
    
    // App Store Server Notification sürüm numarası. (2 veya 1)
    let version: String
    
    // App Store'un JSON Web İmzası verilerini imzaladığı zaman.
    let signedDate: UnixTimestamp
    
    public func verify(using signer: JWTSigner) throws {}
}
