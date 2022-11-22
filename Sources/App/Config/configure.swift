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

    app.sms.configuration = .init(
        accessKeyID: Environment.get("AWS_ACCESS_KEY_ID")!,
        secretAccessKey: Environment.get("AWS_SECRET_ACCESS_KEY")!,
        senderId: Environment.get("AWS_SNS_SENDER_ID")!
    )
    
//    Task {
//        try await app.sms.send(to: "+905533352131", message:"test message")
//    }
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
}

enum ConfigurationError: Error {
    case noAppleJwtPrivateKey, noAppleJwtKid, noAppleJwtIss
}
