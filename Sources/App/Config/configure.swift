import Vapor
import JWT

public func configure(_ app: Application) throws {
    
    app.configureDatabase()
    app.configureViews()
    app.configureMigrations()
    
    try app.configureRedis()
//    try app.configureJWT()
    try app.configureRoutes()
    try app.configureAppleAPN()
    try app.configureAWS()
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
}

struct Example: JWTPayload {
    var test: String
    
    func verify(using signer: JWTSigner) throws {}
}
