import Vapor
import Fluent
import FluentPostgresDriver
import APNS
import JWT

// configures your application
public func configure(_ app: Application) throws {
    
    app.databases.use(
        .postgres(
            hostname: Environment.get("DB_HOST") ?? "vnvce-db-free-tier.cri1kmscggha.eu-central-1.rds.amazonaws.com",
            port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? 5432,
            username: Environment.get("DB_USERNAME") ?? "vnvce_postgres",
            password: Environment.get("DB_PASSWORD") ?? "Onlykrm-26-HOM-AwS-vnvce-postgres-free-tier",
            database: Environment.get("DB_NAME") ?? "vnvce_postgres_db_free_tier"
        ),
        as: .psql
    )
    //helloa
    
    try app.autoMigrate().wait()
    
    try routes(app)
}
