
import Vapor
import Fluent
import JWT
import JWTKit

extension AppStoreServerController: AppStoreServerNotification {
    private struct SignedPayload: Decodable {
        let signedPayload: String
    }
    
    public func notificationsHandler(_ req: Request) async throws -> HTTPStatus {
        let signedNotification = try req.content.decode(SignedPayload.self).signedPayload
        let appStore = req.application.appStoreServer.notification
        
        let payload = try appStore.verifyAll(signedNotification, on: req)
        
        switch payload.payload.notificationType {
            
        case .consumptionRequest:
            print(payload.payload.notificationType.rawValue)
        case .didChangeRenewalPref:
            print(payload.payload.notificationType.rawValue)
        case .didChangeRenewalStatus:
            print(payload.payload.notificationType.rawValue)
        case .didfailToRenew:
            print(payload.payload.notificationType.rawValue)
        case .didRenew:
            print(payload.payload.notificationType.rawValue)
        case .expired:
            print(payload.payload.notificationType.rawValue)
        case .gradePeriodExpired:
            print(payload.payload.notificationType.rawValue)
        case .offeredRedeemed:
            print(payload.payload.notificationType.rawValue)
        case .priceIncrease:
            print(payload.payload.notificationType.rawValue)
        case .refund:
            print(payload.payload.notificationType.rawValue)
        case .refundDeclined:
            print(payload.payload.notificationType.rawValue)
        case .renewalExtended, .renewalExtension:
            print(payload.payload.notificationType.rawValue)
        case .revoke:
            print(payload.payload.notificationType.rawValue)
        case .subscribed:
            print(payload.payload.notificationType.rawValue)
        case .test:
            print(payload.payload.notificationType.rawValue)
        }
        
//        print(
//            """
//            NOTIFICATION
//
//                   [TYPE] \(payload.payload.notificationType.rawValue)
//                [SUBTYPE] \(payload.payload.subtype?.rawValue ?? "-")
//              [BUNDLE ID] \(payload.payload.data.bundleId)
//
//            [TRANSACTION]
//                             [ID] \(payload.transactionInfo?.transactionId ?? "-")
//                  [PURCHASE DATE] \(String(describing: payload.transactionInfo?.purchaseDate.date))
//                [EXPIRATION DATE] \(String(describing: payload.transactionInfo?.expiresDate?.date))
//                       [GROUP ID] \(payload.transactionInfo?.subscriptionGroupIdentifier ?? "-")
//                           [TYPE] \(String(describing: payload.transactionInfo?.type.rawValue))
//                        [USER ID] \(String(describing: payload.transactionInfo?.appAccountToken))
//
//            """
//        )
        
        return .ok
    }
    
    
}
