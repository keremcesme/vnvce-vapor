
import Fluent
import VNVCECore

struct CreatePaymentProvider: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(PaymentProvider.schema)
            .case("appleAppStore")
            .case("googlePlayStore")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(PaymentProvider.schema).delete()
    }
}
