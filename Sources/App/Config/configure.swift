
import Vapor
import Fluent

extension Application {
    public func configure() async throws {
        try await self.startConfigurations()
        
        
        
        
//        let result = try? await User.query(on: self.db)
//            .with(\.$username)
//            .with(\.$profilePicture)
//            .join(child: \.$username)
//            .group(.or) { query in
//                query
//                    .filter(.custom("display_name @@ to_tsquery('ker')"))
//                    .filter(Username.self, \Username.$username, .custom("ilike"), "%ker%")
//            }
//            .all()
//
//        let publicUsers = try? await result?.convertToPrivateV1(on: self.db)
//
//        print(publicUsers)
        
    }
}

extension Application {
    private func startConfigurations() async throws {
        self.configureServer()
        
        self.logger.notice("[ INFO ] Total Configurations: 8")
        
        try await self.configureAWS()
        try await self.configureDatabase()
        try await self.configureRedis()
        try await self.configureJWT()
        try await self.configureAppleAPN()
        
        try self.configureRoutes()
        
        self.configureMigrations()
        self.configureViews()
        
//        try app.configureAppleDeviceCheck()
//
//        try await app.autoRevert()
//        try await app.autoMigrate()
        
        self.logger.notice("[ RESULT ] 🎉 All Configurations Success 🎉")
    }
}
