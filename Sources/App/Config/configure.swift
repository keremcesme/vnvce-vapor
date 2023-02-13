
import Vapor
import Fluent
import JWT

extension Application {
    public func configure() async throws {
        try await self.startConfigurations()
    }
}

extension Application {
    private func startConfigurations() async throws {
        self.configureServer()
        
        self.logger.notice("[ INFO ] Total Configurations: 9")
        
        try await self.configureAWS()
        try await self.configureDatabase()
        try await self.configureRedis()
        try await self.configureJWT()
        try await self.configureAppleAPN()
        try await self.configureAppStoreServer()
        
        try self.configureRoutes()
        
        self.configureMigrations()
        self.configureViews()
        
//        let payload = TestPayload()
//        
//        let token = try self.jwt.signers.sign(payload, typ: "JWT", kid: .iapPrivate)
//
//        print(token)
        
//        try app.configureAppleDeviceCheck()

        

//        do {
////            try await self.autoRevert()
////            try await self.autoMigrate()
////
//            let date = Date()
//            let userID = UUID(uuidString: "7292217d-90b5-4912-a850-1d90dca9f1f4")!
//            let transactionID = "000000007"
//
//            let membership: Membership = try await {
//                if let membership = try await Membership.query(on: self.db)
//                    .filter(\.$user.$id == userID)
//                    .first() {
//                    return membership
//                } else {
//                    let membership = Membership(userID: userID, status: .initialBuy, platform: .ios, latestTransactionID: transactionID)
//                    try await membership.create(on: self.db)
//                    return membership
//                }
//            }()
//
//            let membershipID = try membership.requireID()
//
//            membership.status = .didRenew
//            membership.latestTransactionID = transactionID
//
//            let transaction = AppStoreTransaction(
//                id: transactionID,
//                membershipID: membershipID,
//                userID: userID,
//                originalID: "000000001",
//                productID: "vnvce.membership.monthly",
//                productType: .autoRenewable,
//                currencyCode: "TRY",
//                price: 0.99,
//                purchaseDate: date,
//                expirationDate: date.addingTimeInterval(2592000))
//
//            try await self.db.transaction{
//                try await membership.$transactions.create(transaction, on: $0)
//                try await membership.update(on: $0)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
        
        
        
        
//        let id = UUID()
//        print(id)
//        let userID = UUID(uuidString: "7292217d-90b5-4912-a850-1d90dca9f1f4")!
//        let moment = Moment(id: id, ownerID: userID)
//        try await moment.create(on: self.db)
//        let momentID = try moment.requireID()
//        let media = MomentMediaDetail(momentID: momentID, mediaType: .image, url: "url-")
//        try await media.create(on: self.db)
        
        self.logger.notice("[ RESULT ] 🎉 All Configurations Success 🎉")
    }
}

struct TestPayload: JWTPayload {
    let iss: IssuerClaim
    let iat: IssuedAtClaim
    let exp: ExpirationClaim
    let aud: AudienceClaim
    let bid: String
    
    init() {
        self.iss = .init(value: "8ded864a-aa80-4682-b31a-8f592e59e683")
        self.iat = .init(value: Date())
        self.exp = .init(value: Date().addingTimeInterval(60 * 5))
        self.aud = .init(stringLiteral: "appstoreconnect-v1")
        self.bid = "com.socialayf.vnvce"
        
    }
    
    func verify(using signer: JWTKit.JWTSigner) throws {}
}
