
import Foundation
import Vapor
import Redis
import RediStack

public struct RedisGetResult<R: RedisModel> {
    var payload: R
    var ttl: Int
    
    public init(_ payload: R, ttl: Int) {
        self.payload = payload
        self.ttl = ttl
    }
}

extension Request.Redis {
    public func getTTL(_ key: RedisKey) async throws -> Int {
        guard let nanoseconds = try await self.ttl(key).get().timeAmount?.nanoseconds else {
            throw RedisError.V1.noTTL
        }
        let ttl: Int = Int(nanoseconds / 1_000_000_000)
        return ttl
    }
    
    
    public func getWithTTL<R: RedisModel>(_ key: RedisKey, asJSON: R.Type) async throws -> RedisGetResult<R> {
        let ttl = try await self.getTTL(key)
        guard let payload = try await self.get(key, asJSON: asJSON) else {
            throw RedisError.V1.keyNotFound
        }
        
        return .init(payload, ttl: ttl)
    }
}

extension Application.Redis {
    public func getTTL(_ key: RedisKey) async throws -> Int {
        guard let nanoseconds = try await self.ttl(key).get().timeAmount?.nanoseconds else {
            throw RedisError.V1.noTTL
        }
        let ttl: Int = Int(nanoseconds / 1_000_000_000)
        return ttl
    }
    
    
    public func getWithTTL<R: RedisModel>(_ key: RedisKey, asJSON: R.Type) async throws -> RedisGetResult<R> {
        let ttl = try await self.getTTL(key)
        guard let payload = try await self.get(key, asJSON: asJSON) else {
            throw RedisError.V1.keyNotFound
        }
        
        return .init(payload, ttl: ttl)
    }
}
