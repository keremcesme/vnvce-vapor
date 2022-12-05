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

//-----BEGIN RSA PRIVATE KEY-----\n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\n-----END RSA PRIVATE KEY-----
//
//-----BEGIN PUBLIC KEY-----
//MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoHXDivYXaI7zb9GG76QC
//zstH5PuvUhjCG/Y6cZKoF1+alhFuays5e+OxBfesYTy9QEDzo+sDH5qRN/aBF8gf
//aCeIiQbKKakNYwkuP2xOcovd4xeNv35QLnXmPl4QW9aP2AWT8konEp8vsIUZfI7Q
//k6LZ/EbHUFXq3uW5lqjXkUY6JB2h3KzlOAixO9VnvsYzoi9APBbl0Z+ax+RhAsnh
//K/6OxxWwTxf9aykWMqMrFBmWmpJdPCUWKmRqySBl8ieZULFdK/lE677DH3zOAf/D
//1Nf6n10Wf7kB4e77eZog1I9M/Gg6y9qTnAb0SoL4nyS+8Uy90SnZZL11Oi8gxaVA
//7oXpTCxstK+XIjpMX9EwICVMTG45oxZBl7SEMMJsLjvCQx6ccrqDucrtGreGHg6T
//88Y6qumpxgqbDYsGQU+EfDTUo1zcqc/2mG6Nmapdrc3EDngWLwcOoewQtEST32Td
//vZOb7fAugThyJHieCYSX6VL16WGHNHvYHxarpdBSh5BYt0om97EJP/WSw8dECYyO
//oI9D4OnWCNcCw6RqWMgECW13IzYGhsokU42cZqsq8zPO8OMmrXcUfcm/O1lS7+n1
//0tlJz1erDg/XL6B2lNYEuIoV9bTHyIqj34c4XH9Gq30+DWvv277ZsCLdkYH9X0Tk
//wr0eD6pt8P8W6rqSav9idY8CAwEAAQ==
//-----END PUBLIC KEY-----
