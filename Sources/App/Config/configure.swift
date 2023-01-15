
import Vapor
import Fluent
import VNVCECore
import Leaf
import Redis

public func configure(_ app: Application) async throws {
    
    app.http.server.configuration.supportPipelining = true
    app.http.server.configuration.responseCompression = .enabled
    app.http.server.configuration.requestDecompression = .enabled
    app.http.server.configuration.tcpNoDelay = true
    
    switch app.environment {
    case .production:
        app.logger.notice("[ MODE ] Running in Production")
    default:
        app.logger.notice("[ MODE ] Running in Development")
    }
    
    app.logger.notice("[ INFO ] Total Configurations: 8")
    app.views.use(.leaf)
    
    try await app.configureAWS()
    try await app.configureDatabase()
    try await app.configureRedis()
    try await app.configureJWT()
    try await app.configureAppleAPN()
    try await app.configureRoutes()
    
    await app.configureMigrations()
    await app.configureViews()
    
//    try app.configureAppleDeviceCheck()
    
//    try await app.autoRevert()
//    try await app.autoMigrate()
    
    app.logger.notice("[ RESULT ] 🎉 All Configurations Success 🎉")
}
