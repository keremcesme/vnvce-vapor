
import Vapor
import Redis
import RediStack

extension Request.Redis {
    public func drop(_ keys: [RedisKey]) async {
        for key in keys {
            await drop(key)
        }
    }
    
    public func drop(_ keys: RedisKey) async {
        _ = try? await self.delete(keys).get()
    }
}

extension Application.Redis {
    public func drop(_ keys: [RedisKey]) async {
        for key in keys {
            await drop(key)
        }
    }
    
    public func drop(_ keys: RedisKey) async {
        _ = try? await self.delete(keys).get()
    }
}

