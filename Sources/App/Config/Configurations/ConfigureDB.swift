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
    
    private struct DBCredentialsModel: Decodable {
        public static let schema = "DB_CREDENTIALS"
        
        let host: String
        let port: Int
        let username: String
        let password: String
        let name: String
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.host = try container.decode(String.self, forKey: CodingKeys.host)
            self.port = Int(try container.decode(String.self, forKey: CodingKeys.port))!
            self.username = try container.decode(String.self, forKey: CodingKeys.username)
            self.password = try container.decode(String.self, forKey: CodingKeys.password)
            self.name = try container.decode(String.self, forKey: CodingKeys.name)
        }
        
        enum CodingKeys: String, CodingKey {
            case host = "HOST"
            case port = "PORT"
            case username = "USERNAME"
            case password = "PASSWORD"
            case name = "NAME"
        }
    }
    
    public func configureDatabase() async throws {
        self.logger.notice("[ 2/9 ] Configuring Database (PSQL)")
        
        let credentials = try await self.aws.secrets.getSecret(DBCredentialsModel.schema, to: DBCredentialsModel.self)
        
        self.databases.use(
            .postgres(
                hostname: credentials.host,
                port: credentials.port,
                username: credentials.username,
                password: credentials.password,
                database: credentials.name),
            as: .psql
        )
        
        self.logger.notice("✅ Database Configured")
    }
}

