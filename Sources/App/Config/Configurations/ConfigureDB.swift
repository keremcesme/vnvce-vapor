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
    public func configureDatabase() {
        self.databases.use(
            .postgres(
                hostname: Environment.get("DB_HOST") ?? "localhost",
                port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
                username: Environment.get("DB_USERNAME") ?? "vapor_username",
                password: Environment.get("DB_PASSWORD") ?? "vapor_password",
                database: Environment.get("DB_NAME") ?? "vapor_database"
            ),
            as: .psql
        )
    }
}
