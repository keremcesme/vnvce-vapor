import Vapor
import Fluent
import FluentPostgresDriver
import FluentPostGIS
import APNS
import JWT
import SotoSNS
import Leaf
import LeafKit
import Redis
import Queues
import QueuesRedisDriver

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
    
//    app.redis.configuration = try RedisConfiguration(hostname: "localhost")
    
    app.redis.configuration = try RedisConfiguration(hostname: Environment.get("REDIS_HOST") ?? "localhost", port:6379 )
    
//    6379
    
    
    // Views
    app.routes.defaultMaxBodySize = "10mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)
    
    
//    app.http.server.configuration.supportVersions = [.two]
//    try app.http.server.configuration.tlsConfiguration = .makeClientConfiguration()
    
//    app.migrations.add(EnablePostGISMigration())
    
    runMigrations(app)
    
//    try app.autoRevert().wait()
    try app.autoMigrate().wait()
    
//    try app.queues.use(.redis(RedisConfiguration(hostname: "localhost")))
//    try app.queues.startInProcessJobs()
//    try app.queues.startScheduledJobs()
    
    try routes(app)
    try app.configureAppleAPN()
    
    app.smsSender = try configureSMSSender()
    
    app.s3 = try configureS3()
    
}
