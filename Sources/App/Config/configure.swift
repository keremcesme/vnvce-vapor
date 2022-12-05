import Vapor
import VNVCECore

enum ConfigurePhase: Logger.Message {
    case asdf = "asdf"
}

enum ConfigureError: Logger.Message, Error {
    case missingDBEnvironments = "❌ Missing DB Environments"
    case missingRedisEnvironments = "❌ Missing Redis Environments"
    
    case missingRSAKeys = "❌ Missing RSA keys for JWT"
    case missingRSAPublicKey = "❌ Missing RSA public key for JWT"
    case missingRSAPrivateKey = "❌ Missing RSA private keyfor JWT"
    
    case missingAWSEnvironments = "❌ Missing AWS Environments"
    case missingAppleAPNSEnvironments = "❌ Missing Apple APNs Environments"
}

public func configure(_ app: Application) async throws {
    
//    app.http.server.configuration.supportPipelining = true
//    app.http.server.configuration.responseCompression = .enabled
//    app.http.server.configuration.requestDecompression = .enabled
//    app.http.server.configuration.tcpNoDelay = true
    
    switch app.environment {
    case .production:
        app.logger.notice("[ MODE ] Running in Production")
    default:
        app.logger.notice("[ MODE ] Running in Development")
    }
    
    app.logger.notice("Total Configurations: 8")
    
    try await app.configureDatabase()
    try await app.configureRedis()
    try await app.configureAppleAPN()
    try await app.configureAWSSMS()
    try await app.configureJWT()
    try await app.configureRoutes()

    await app.configureMigrations()
    await app.configureViews()
    
    app.logger.notice("✅ Configurations Success")
    
    
//    try app.configureAppleDeviceCheck()
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
    
}
