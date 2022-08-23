import Vapor
import Fluent
import FluentPostgresDriver
import APNS
import JWT
import SNS

public func configure(_ app: Application) throws {
    
    app.databases.use(
        .postgres(
            hostname: Environment.get("DB_HOST") ?? "localhost",
            port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: Environment.get("DB_USERNAME") ?? "vapor_username",
            password: Environment.get("DB_PASSWORD") ?? "vapor_password",
            database: Environment.get("DB_NAME") ?? "vapor_database"
        ),
        as: .psql
    )
    
    runMigrations(app)
    
    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    
    try routes(app)
    try app.configureAppleAPN()
    
    app.smsSender = try configureSMSSender()
}
