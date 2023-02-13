
import Fluent
import FluentSQL
import VNVCECore

struct CreateAppStoreTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let productType = try await database.enum(AppStoreProductType.schema).read()
        let ownershipType = try await database.enum(AppStoreProductOwnershipType.schema).read()
        let offerType = try await database.enum(AppStoreOfferType.schema).read()
        let revocationReason = try await database.enum(AppStoreRevocationReason.schema).read()
        
        try await database.schema(AppStoreTransaction.schema)
            .field(.id, .string, .required, .identifier(auto: false))
            .field("membership_id", .uuid, .required, .references(Membership.schema, .id, onDelete: .noAction))
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .noAction))
            .field("original_id", .string)
            .field("web_order_line_item_id", .string)
            .field("product_id", .string, .required)
            .field("product_type", productType, .required)
            .field("subscription_group_id", .string)
            .field("is_upgraded", .bool, .required)
            .field("currency_code", .sql(raw: "char(3)"), .required)
            .field("price", .sql(raw: "numeric"), .required)
            .field("purchase_date", .datetime, .required)
            .field("expiration_date", .datetime)
            .field("ownership_type", ownershipType, .required)
            .field("purchased_quantity", .int, .required)
            .field("offer_id", .string)
            .field("offer_type", offerType)
            .field("revocation_date", .datetime)
            .field("revocation_reason", revocationReason)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(AppStoreTransaction.schema).delete()
    }
}
