
import Vapor
import VNVCECore

extension VNVCECore.AppStoreTransaction.V1 {
    
    func convert(_ membershipID: Membership.IDValue, userID: User.IDValue) -> AppStoreTransaction {
        let id = String(self.id)
        let originalID = String(self.originalID)
        let transaction = AppStoreTransaction(
            id: id,
            membershipID: membershipID,
            userID: userID,
            originalID: originalID,
            webOrderLineItemID: self.webOrderLineItemID,
            productID: self.productID,
            productType: self.productType,
            subscriptionGroupID: self.subscriptionGroupID,
            isUpgraded: self.isUpgraded,
            purchaseDate: self.purchaseDate,
            expirationDate: self.expirationDate,
            ownershipType: self.ownershipType,
            purchasedQuantity: self.purchasedQuantity,
            offerID: self.offerID,
            offerType: self.offerType ?? .none,
            revocationDate: self.revocationDate,
            revocationReason: self.revocationReason)
        
        return transaction
    }
    
}
