
import Vapor
import Redis
import RediStack

extension Request.Redis {
    public func drop(_ keys: [RedisKey]) async throws {
        _ = try await self.delete(keys).get()
    }
    
    public func drop(_ keys: RedisKey) async throws {
        _ = try await self.delete(keys).get()
    }
}

extension Application.Redis {
    public func drop(_ keys: [RedisKey]) async throws {
        _ = try await self.delete(keys).get()
    }
    
    public func drop(_ keys: RedisKey) async throws {
        _ = try await self.delete(keys).get()
    }
}

