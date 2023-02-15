
import Vapor
import Fluent
import VNVCECore

extension AppStoreServerController: AppStoreServerNotification {
    private struct SignedPayload: Decodable {
        let signedPayload: String
        
        static func decode(_ req: Request) throws -> String {
            return try req.content.decode(Self.self).signedPayload
        }
    }
    
    public func notificationsHandler(_ req: Request) async throws -> HTTPStatus {
        let appStore = req.application.appStoreServer.notification
        
        let signedPayload = try SignedPayload.decode(req)
        
        let notification = try appStore.verifyAll(signedPayload, on: req)
        
        print("NOTIFICATION RECEIVED: ID \(notification.transactionInfo!.transactionId)")
        
        try await req.db.transaction {
            let membership = try await transactionHandler(notification.transactionInfo, on: $0)
            try await updateMembership(notification, membership: membership, on: $0)
        }
        
        return .ok
    }
    
    private func transactionHandler(_ info: TransactionInfo?, on db: Database) async throws -> Membership? {
        return try await {
            if let info, let membership = try await Membership.query(on: db).filter(\.$user.$id == info.appAccountToken).first() {
                
                if let transaction = try await AppStoreTransaction.find(info.transactionId, on: db) {
                    try await updateTransaction(info, transaction: transaction, on: db)
                } else {
                    try await createTransaction(info, membership: membership, on: db)
                }
                return membership
            } else {
                return nil
            }
        }()
    }
    
    private func createTransaction(_ info: TransactionInfo, membership: Membership, on db: Database) async throws {
        var originalID: String? {
            if info.transactionId != info.originalTransactionId {
                return info.originalTransactionId
            } else {
                return nil
            }
        }
        
        var originalPurchaseDate: Date? {
            if info.purchaseDate.date != info.originalPurchaseDate?.date {
                return info.originalPurchaseDate?.date
            } else {
                return nil
            }
        }

        let membershipID = try membership.requireID()
        
        let transaction = AppStoreTransaction(
            id: info.transactionId,
            originalID: originalID,
            membershipID: membershipID,
            userID: info.appAccountToken,
            webOrderLineItemID: info.webOrderLineItemId,
            subscriptionGroupID: info.subscriptionGroupIdentifier,
            productID: info.productId,
            productType: info.type.convert,
            isUpgraded: info.isUpgraded,
            ownershipType: info.inAppOwnershipType.convert,
            purchasedQuantity: info.quantity,
            offerID: info.offerIdentifier,
            offerType: info.offerType?.convertOfferType,
            revocationReason: info.revocationReason?.convertRevocationReason,
            purchaseDate: info.purchaseDate.date,
            originalPurchaseDate: originalPurchaseDate,
            expirationDate: info.expiresDate?.date,
            revocationDate: info.revocationDate?.date,
            signedDate: info.signedDate.date)
        
        try await membership.$transactions.create(transaction, on: db)
    }
    
    private func updateTransaction(_ info: TransactionInfo, transaction: AppStoreTransaction, on db: Database) async throws {
        
        var originalID: String? {
            if info.transactionId != info.originalTransactionId {
                return info.originalTransactionId
            } else {
                return nil
            }
        }
        
        var originalPurchaseDate: Date? {
            if info.purchaseDate.date != info.originalPurchaseDate?.date {
                return info.originalPurchaseDate?.date
            } else {
                return nil
            }
        }
        
        transaction.originalID = originalID
        transaction.webOrderLineItemID = info.webOrderLineItemId
        transaction.subscriptionGroupID = info.subscriptionGroupIdentifier
        transaction.productID = info.productId
        transaction.productType = info.type.convert
        transaction.isUpgraded = info.isUpgraded
        transaction.ownershipType = info.inAppOwnershipType.convert
        transaction.purchasedQuantity = info.quantity
        transaction.offerID = info.offerIdentifier
        transaction.offerType = info.offerType?.convertOfferType
        transaction.revocationReason = info.revocationReason?.convertRevocationReason
        transaction.purchaseDate = info.purchaseDate.date
        transaction.originalPurchaseDate = originalPurchaseDate
        transaction.expirationDate = info.expiresDate?.date
        transaction.revocationDate = info.revocationDate?.date
        transaction.signedDate = info.signedDate.date
        
        try await transaction.update(on: db)
    }
    
    private func updateMembership(_ notification: NotificationPayloadAll, membership: Membership?, on db: Database) async throws {
        guard let membership else {
            return
        }
        
        switch notification.payload.notificationType {
        case .consumptionRequest:
            membership.status = .consumptionRequested
        case .didChangeRenewalPref:
            switch notification.payload.subtype {
            case .upgrade:
                membership.status = .renewalPrefUpgraded
            case .downgrade:
                membership.status = .renewalPrefDowngraded
            default:
                return
            }
        case .didChangeRenewalStatus:
            switch notification.payload.subtype {
            case .autoRenewEnabled:
                membership.status = .autoRenewEnabled
            case .autoRenewDisabled:
                membership.status = .autoRenewDisabled
            default:
                return
            }
        case .didfailToRenew:
            guard let subtype = notification.payload.subtype else {
                membership.status = .billingIssue
                break
            }
            if case .gracePeriod = subtype {
                membership.status = .gracePeriod
            } else {
                return
            }
        case .didRenew:
            guard let subtype = notification.payload.subtype else {
                membership.status = .didRenew
                break
            }
            if case .billingRecovery = subtype {
                membership.status = .didRenewWithBillingRecovery
            } else {
                return
            }
        case .expired:
            guard let subtype = notification.payload.subtype else {
                membership.status = .expiredOther
                break
            }
            switch subtype {
            case .voluntary:
                membership.status = .voluntary
            case .billingRetry:
                membership.status = .billingRetryFailed
            case .priceIncrease:
                membership.status = .priceIncreaseDenied
            case .productNotForSale:
                membership.status = .productNotForSale
            default:
                return
            }
        case .gradePeriodExpired:
            membership.status = .gracePeriodExpired
        case .offeredRedeemed:
            guard let subtype = notification.payload.subtype else {
                membership.status = .offerRedeemedForCurrent
                break
            }
            switch subtype {
            case .initialBuy:
                membership.status = .offerRedeemedForInitialBuy
            case .resubscribe:
                membership.status = .offerRedeemedForResubscribe
            case .upgrade:
                membership.status = .offerRedeemedForUpgrade
            case .downgrade:
                membership.status = .offerRedeemedForDowngrade
            default:
                return
            }
        case .priceIncrease:
            guard let subtype = notification.payload.subtype else {
                return
            }
            switch subtype {
            case .accepted:
                membership.status = .priceIncreaseAccepted
            case .pending:
                membership.status = .priceIncreasePending
            default:
                return
            }
        case .refund:
            membership.status = .refunded
        case .refundDeclined:
            membership.status = .refundDeclined
        case .renewalExtended, .renewalExtension:
            membership.status = .renewalExtended
        case .revoke:
            membership.status = .revoked
        case .subscribed:
            guard let subtype = notification.payload.subtype else {
                return
            }
            switch subtype {
            case .initialBuy:
                membership.status = .initialBuy
            case .resubscribe:
                membership.status = .resubscribe
            default:
                return
            }
        case .test:
            return
        }
        
        membership.provider = .appleAppStore
        membership.isActive = membership.status.isActive
        
        try await membership.update(on: db)
    }
    
}
