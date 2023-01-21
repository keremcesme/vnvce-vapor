
import Vapor

extension Application {
    public func configure() async throws {
        try await self.startConfigurations()
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
