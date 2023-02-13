
import Fluent
import VNVCECore

struct CreateMembershipStatus: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(MembershipStatus.schema)
            .case("initialBuy")
            .case("resubscribe")
            .case("billingIssue")
            .case("gracePeriod")
            .case("renewalPrefUpgraded")
            .case("renewalPrefDowngraded")
            .case("renewalPrefGivedUp")
            .case("autoRenewEnabled")
            .case("autoRenewDisabled")
            .case("didRenew")
            .case("didRenewWithBillingRecovery")
            .case("voluntary")
            .case("billingRetryFailed")
            .case("priceIncreaseDenied")
            .case("productNotForSale")
            .case("gracePeriodExpired")
            .case("offerRedeemedForInitialBuy")
            .case("offerRedeemedForResubscribe")
            .case("offerRedeemedForUpgrade")
            .case("offerRedeemedForDowngrade")
            .case("priceIncreaseAccepted")
            .case("priceIncreasePending")
            .case("refunded")
            .case("consumptionRequested")
            .case("refundDeclined")
            .case("lifetime")
            .case("none")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(MembershipStatus.schema).delete()
    }
}
