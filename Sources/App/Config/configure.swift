
import Vapor
import Fluent

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

//        try await self.autoRevert()
//        try await self.autoMigrate()
        
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
