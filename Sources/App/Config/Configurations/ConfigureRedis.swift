//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Redis

extension Application {
    func configureRedis() throws {
        // MARK: PROD
        self.redis.configuration = try RedisConfiguration(
            hostname: Environment.get("REDIS_HOST") ?? "localhost",
            port: getRedisPort())
        
        // MARK: DEV
//        self.redis.configuration = try RedisConfiguration(hostname: "localhost")
    }
    
    private func getRedisPort() -> Int {
        if let envPort = Environment.get("REDIS_PORT"),
           let port = Int(envPort) {
            return port
        } else {
            return 6379
        }
    }
}
