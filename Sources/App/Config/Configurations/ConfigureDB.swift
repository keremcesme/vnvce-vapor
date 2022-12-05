//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Fluent
import FluentPostgresDriver

fileprivate enum EnvironmentKey {
    static let host = Environment.get("DB_HOST")
    static let port = Environment.get("DB_PORT")
    static let username = Environment.get("DB_USERNAME")
    static let password = Environment.get("DB_PASSWORD")
    static let database = Environment.get("DB_NAME")
}

extension Application {
    public func configureDatabase() async throws {
        self.logger.notice("[ 1/8 ] Configuring Database (PSQL)")
        
        guard
            let host = EnvironmentKey.host,
            let port = EnvironmentKey.port.flatMap(Int.init),
            let username = EnvironmentKey.username,
            let password = EnvironmentKey.password,
            let database = EnvironmentKey.database
        else {
            let error = ConfigureError.missingDBEnvironments
            self.logger.notice(error.rawValue)
            throw error
        }
        
        self.databases.use(
            .postgres(
                hostname: host,
                port: port,
                username: username,
                password: password,
                database: database),
            as: .psql
        )
        
        self.logger.notice("✅ Database Configured")
    }
}
