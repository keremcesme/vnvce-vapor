
import Vapor
import Fluent
import VNVCECore

final class AppStoreTransaction: Model, Content {
    static let schema = "appstore_tansactions"
    // IDs
    @ID(custom: "id")
    var id: String?
    @OptionalField(key: "original_transaction_id")
    var originalID: String?
    @OptionalParent(key: "membership_id")
    var membership: Membership?
    @Parent(key: "user_id")
    var user: User
    @OptionalField(key: "web_order_line_item_id")
    var webOrderLineItemID: String?
    @OptionalField(key: "subscription_group_id")
    var subscriptionGroupID: String?
    @Field(key: "product_id")
    var productID: String
    @Enum(key: "product_type")
    var productType: AppStoreProductType
    @OptionalField(key: "is_upgraded")
    var isUpgraded: Bool?
    @Enum(key: "ownership_type")
    var ownershipType: AppStoreProductOwnershipType
    @Field(key: "purchased_quantity")
    var purchasedQuantity: Int
    
    // OFFER
    @OptionalField(key: "offer_id")
    var offerID: String?
    @OptionalEnum(key: "offer_type")
    var offerType: AppStoreOfferType?
    
    // REVOKE
    @OptionalEnum(key: "revocation_reason")
    var revocationReason: AppStoreRevocationReason?
    
    // DATES
    @Field(key: "purchase_date")
    var purchaseDate: Date
    @OptionalField(key: "original_purchase_date")
    var originalPurchaseDate: Date?
    @OptionalField(key: "expiration_date")
    var expirationDate: Date?
    @OptionalField(key: "revocation_date")
    var revocationDate: Date?
    @Field(key: "signed_date")
    var signedDate: Date
    
    init() {}
    
    init(
        id: String,
        originalID: String?,
        membershipID: Membership.IDValue?,
        userID: User.IDValue,
        webOrderLineItemID: String?,
        subscriptionGroupID: String?,
        productID: String,
        productType: AppStoreProductType,
        isUpgraded: Bool?,
        ownershipType: AppStoreProductOwnershipType,
        purchasedQuantity: Int,
        offerID: String?,
        offerType: AppStoreOfferType?,
        revocationReason: AppStoreRevocationReason?,
        purchaseDate: Date,
        originalPurchaseDate: Date?,
        expirationDate: Date?,
        revocationDate: Date?,
        signedDate: Date
    ) {
        self.id = id
        self.originalID = originalID
        self.$membership.id = membershipID
        self.$user.id = userID
        self.webOrderLineItemID = webOrderLineItemID
        self.subscriptionGroupID = subscriptionGroupID
        self.productID = productID
        self.productType = productType
        self.isUpgraded = isUpgraded
        self.ownershipType = ownershipType
        self.purchasedQuantity = purchasedQuantity
        self.offerID = offerID
        self.offerType = offerType
        self.revocationReason = revocationReason
        self.purchaseDate = purchaseDate
        self.originalPurchaseDate = originalPurchaseDate
        self.expirationDate = expirationDate
        self.revocationDate = revocationDate
        self.signedDate = signedDate
    }
    
}
