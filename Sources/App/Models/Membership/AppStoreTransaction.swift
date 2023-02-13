
import Vapor
import Fluent
import VNVCECore

final class AppStoreTransaction: Model, Content {
    static let schema = "appstore_tansactions"
    
    @ID(custom: "id")
    var id: String?
    
    @Parent(key: "membership_id")
    var membership: Membership
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalField(key: "original_id")
    var originalID: String?
    
    @OptionalField(key: "web_order_line_item_id")
    var webOrderLineItemID: String?
    
    @Field(key: "product_id")
    var productID: String
    
    @Enum(key: "product_type")
    var productType: AppStoreProductType
    
    @OptionalField(key: "subscription_group_id")
    var subscriptionGroupID: String?
    
    @Field(key: "is_upgraded")
    var isUpgraded: Bool
    
    @Field(key: "currency_code")
    var currencyCode: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "purchase_date")
    var purchaseDate: Date
    
    @OptionalField(key: "expiration_date")
    var expirationDate: Date?
    
    @Enum(key: "ownership_type")
    var ownershipType: AppStoreProductOwnershipType
    
    @Field(key: "purchased_quantity")
    var purchasedQuantity: Int
    
    @OptionalField(key: "offer_id")
    var offerID: String?
    
    @Enum(key: "offer_type")
    var offerType: AppStoreOfferType
    
    @OptionalField(key: "revocation_date")
    var revocationDate: Date?
    
    @OptionalEnum(key: "revocation_reason")
    var revocationReason: AppStoreRevocationReason?
    
    
    init() {}
    
    init(
        id: String,
        membershipID: Membership.IDValue,
        userID: User.IDValue,
        originalID: String? = nil,
        webOrderLineItemID: String? = nil,
        productID: String,
        productType: AppStoreProductType = .autoRenewable,
        subscriptionGroupID: String? = nil,
        isUpgraded: Bool = false,
        currencyCode: String,
        price: Double,
        purchaseDate: Date,
        expirationDate: Date? = nil,
        ownershipType: AppStoreProductOwnershipType = .purchased,
        purchasedQuantity: Int = 1,
        offerID: String? = nil,
        offerType: AppStoreOfferType = .none,
        revocationDate: Date? = nil,
        revocationReason: AppStoreRevocationReason? = nil
    ) {
        self.id = id
        self.$membership.id = membershipID
        self.$user.id = userID
        self.originalID = originalID
        self.webOrderLineItemID = webOrderLineItemID
        self.productID = productID
        self.productType = productType
        self.subscriptionGroupID = subscriptionGroupID
        self.isUpgraded = isUpgraded
        self.currencyCode = currencyCode
        self.price = price
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.ownershipType = ownershipType
        self.purchasedQuantity = purchasedQuantity
        self.offerID = offerID
        self.offerType = offerType
        self.revocationDate = revocationDate
        self.revocationReason = revocationReason
    }
    
}
