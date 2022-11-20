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
        //    app.redis.configuration = try RedisConfiguration(
        //        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        //        port:6379)

        // MARK: DEV
        self.redis.configuration = try RedisConfiguration(hostname: "localhost")
    }
}
