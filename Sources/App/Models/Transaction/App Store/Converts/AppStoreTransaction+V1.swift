
import Vapor
import Fluent
import VNVCECore

extension VNVCECore.AppStoreTransaction.V1 {
    
    func create(_ membership: Membership, on db: Database) async throws {
        
        var originalID: String? {
            if self.id != self.originalID {
                return self.originalID
            } else {
                return nil
            }
        }
        
        var originalPurchaseDate: Date? {
            if self.purchaseDate != self.originalPurchaseDate {
                return self.originalPurchaseDate
            } else {
                return nil
            }
        }
        
        let membershipID = try membership.requireID()
        
        let transaction = AppStoreTransaction(
            id: self.id,
            originalID: originalID,
            membershipID: membershipID,
            userID: self.appAccountToken,
            webOrderLineItemID: self.webOrderLineItemID,
            subscriptionGroupID: self.subscriptionGroupID,
            productID: self.productID,
            productType: self.productType,
            isUpgraded: self.isUpgraded,
            ownershipType: self.ownershipType,
            purchasedQuantity: self.purchasedQuantity,
            offerID: self.offerID,
            offerType: self.offerType,
            revocationReason: self.revocationReason,
            purchaseDate: self.purchaseDate,
            originalPurchaseDate: originalPurchaseDate,
            expirationDate: self.expirationDate,
            revocationDate: self.revocationDate,
            signedDate: self.signedDate)
        
        try await membership.$transactions.create(transaction, on: db)
    }
    
    func update(_ transaction: AppStoreTransaction, on db: Database) async throws {
        var originalID: String? {
            if self.id != self.originalID {
                return self.originalID
            } else {
                return nil
            }
        }
        
        var originalPurchaseDate: Date? {
            if self.purchaseDate != self.originalPurchaseDate {
                return self.originalPurchaseDate
            } else {
                return nil
            }
        }
        
        transaction.originalID = originalID
        transaction.webOrderLineItemID = self.webOrderLineItemID
        transaction.subscriptionGroupID = self.subscriptionGroupID
        transaction.productID = self.productID
        transaction.productType = self.productType
        transaction.isUpgraded = self.isUpgraded
        transaction.ownershipType = self.ownershipType
        transaction.purchasedQuantity = self.purchasedQuantity
        transaction.offerID = self.offerID
        transaction.offerType = self.offerType
        transaction.revocationReason = self.revocationReason
        transaction.purchaseDate = self.purchaseDate
        transaction.originalPurchaseDate = originalPurchaseDate
        transaction.expirationDate = self.expirationDate
        transaction.revocationDate = self.revocationDate
        transaction.signedDate = self.signedDate
        
        try await transaction.update(on: db)
    }
    
}
