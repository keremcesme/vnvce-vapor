import Vapor
import Backtrace
import VNVCECore

public func configure(_ app: Application) throws {
    Backtrace.install()
    
    app.configureDatabase()
    app.configureViews()
    app.configureMigrations()
    app.configureAWSSMS()
    
    try app.configureRedis()
    try app.configureJWT()
    try app.configureRoutes()
    try app.configureAppleAPN()
    try app.configureAppleDeviceCheck()
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
    
}
