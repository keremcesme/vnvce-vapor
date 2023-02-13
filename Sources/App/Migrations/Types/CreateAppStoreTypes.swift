
import Fluent
import VNVCECore

struct CreateAppStoreTypes: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(AppStoreProductType.schema)
            .case("autoRenewable")
            .case("nonRenewing")
            .case("nonConsumable")
            .case("consumable")
            .create()
        
        _ = try await database
            .enum(AppStoreOfferType.schema)
            .case("introductory")
            .case("promotional")
            .case("code")
            .case("none")
            .create()
        
        _ = try await database
            .enum(AppStoreProductOwnershipType.schema)
            .case("familyShared")
            .case("purchased")
            .create()
        
        _ = try await database
            .enum(AppStoreRevocationReason.schema)
            .case("developerIssue")
            .case("other")
            .create()
    }
    
    func revert(on database: Database) async throws {
        _ = try await database.enum(AppStoreRevocationReason.schema).delete()
        _ = try await database.enum(AppStoreProductOwnershipType.schema).delete()
        _ = try await database.enum(AppStoreOfferType.schema).delete()
        _ = try await database.enum(AppStoreProductType.schema).delete()
    }
}
