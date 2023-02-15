
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
            .case("autoRenewEnabled")
            .case("autoRenewDisabled")
            .case("didRenew")
            .case("didRenewWithBillingRecovery")
            .case("voluntary")
            .case("billingRetryFailed")
            .case("priceIncreaseDenied")
            .case("productNotForSale")
            .case("expiredOther")
            .case("gracePeriodExpired")
            .case("offerRedeemedForInitialBuy")
            .case("offerRedeemedForResubscribe")
            .case("offerRedeemedForUpgrade")
            .case("offerRedeemedForDowngrade")
            .case("offerRedeemedForCurrent")
            .case("priceIncreaseAccepted")
            .case("priceIncreasePending")
            .case("refunded")
            .case("consumptionRequested")
            .case("refundDeclined")
            .case("renewalExtended")
            .case("revoked")
            .case("lifetime")
            .case("none")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(MembershipStatus.schema).delete()
    }
}
