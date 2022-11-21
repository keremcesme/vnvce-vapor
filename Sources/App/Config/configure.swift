import Vapor


public func configure(_ app: Application) throws {
    
    app.configureDatabase()
    app.configureViews()
    app.configureMigrations()
    
    try app.configureRedis()
    try app.configureJWT()
    try app.configureRoutes()
    try app.configureAppleAPN()
    try app.configureAppleDeviceCheck()
    try app.configureAWS()
    
    
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
}

enum ConfigurationError: Error {
    case noAppleJwtPrivateKey, noAppleJwtKid, noAppleJwtIss
}
