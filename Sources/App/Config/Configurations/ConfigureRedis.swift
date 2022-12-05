//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Redis

fileprivate enum EnvironmentKey {
    static let host = Environment.get("REDIS_HOST")
    static let port = Environment.get("REDIS_PORT")
}

extension Application {
    func configureRedis() async throws {
        self.logger.notice("[ 2/8 ] Configuring Redis")
        
        switch self.environment {
        case .production:
            guard
                let host = EnvironmentKey.host,
                let portRaw = EnvironmentKey.port,
                let port = Int(portRaw)
            else {
                let error = ConfigureError.missingRedisEnvironments
                self.logger.notice(error.rawValue)
                throw error
            }
            
            self.redis.configuration = try RedisConfiguration(
                hostname: host,
                port: port)
            
            self.logger.notice("✅ Redis Configured")
            
        default:
            self.redis.configuration = try RedisConfiguration(
                hostname: "localhost")
            
            self.logger.notice("✅ Redis Configured")
        }
    }
}
