//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Fluent
import FluentPostgresDriver

extension Application {
    public func configureDatabase() async throws {
        self.logger.notice("[ 1/8 ] Configuring Database (PSQL)")
        
        guard
            let host = Environment.get("DB_HOST"),
            let port = Environment.get("DB_PORT").flatMap(Int.init),
            let username = Environment.get("DB_USERNAME"),
            let password = Environment.get("DB_PASSWORD"),
            let database = Environment.get("DB_NAME")
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

