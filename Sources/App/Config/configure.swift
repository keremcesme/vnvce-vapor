
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
        
        try await self.configureMigrations()
        self.configureViews()
        
//        try app.configureAppleDeviceCheck()
        
        self.logger.notice("[ RESULT ] 🎉 All Configurations Success 🎉")
    }
}

//struct TestPayload: JWTPayload {
//    let iss: IssuerClaim
//    let iat: IssuedAtClaim
//    let exp: ExpirationClaim
//    let aud: AudienceClaim
//    let bid: String
//
//    init() {
//        self.iss = .init(value: "8ded864a-aa80-4682-b31a-8f592e59e683")
//        self.iat = .init(value: Date())
//        self.exp = .init(value: Date().addingTimeInterval(60 * 5))
//        self.aud = .init(stringLiteral: "appstoreconnect-v1")
//        self.bid = "com.socialayf.vnvce"
//
//    }
//
//    func verify(using signer: JWTKit.JWTSigner) throws {}
//}
