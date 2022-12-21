
import Foundation
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

public extension AuthService.Redis.V1 {
    // MARK: - REFRESH TOKEN -
    typealias RefreshToken = Redis.RefreshToken.V1
    typealias RefreshTokenGetResult = RedisGetResult<RefreshToken>
    
    /// Store `Refresh Token` to Redis database.
    func addRefreshToken(_ refreshTokenID: String) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = RefreshToken()
        let ttl = TTL.refreshToken
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Get `Refresh Token` from Redis database.
    func getRefreshToken(_ refreshTokenID: String) async -> RefreshToken? {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = try? await self.app.redis.get(key, asJSON: RefreshToken.self)
        return payload
    }
    
    /// Get `Refresh Token` with TTL from Redis database.
    func getRefreshTokenWithTTL(_ refreshTokenID: String) async -> RefreshTokenGetResult? {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = try? await self.app.redis.get(key, asJSON: RefreshToken.self)
        let ttl = try? await self.app.redis.getTTL(key)
        if let payload, let ttl {
            return .init(payload, ttl: ttl)
        } else {
            return nil
        }
    }
    
    /// Revokes the `Refresh Token` from the Redis database.
    /// If the `TTL` value cannot be supplied, this method will automatically
    /// get the `TTL` value from the database. Performs extra task.
    func revokeRefreshToken(_ refreshTokenID: String) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        if var result = try? await self.app.redis.getWithTTL(key, asJSON: RefreshToken.self) {
            if result.payload.is_active {
                result.payload.is_active = false
                try? await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
            }
        }
    }
    
    func verifyRefreshToken(rtID refreshTokenID: String) async -> Bool {
        let key = refreshTokenRedisBucket(refreshTokenID)
        guard let payload = try? await self.app.redis.get(key, asJSON: RefreshToken.self) else {
            return false
        }
        return payload.is_active
    }
    
    func verifyRefreshToken(rt refreshToken: RefreshToken) -> Bool {
        return refreshToken.is_active
    }
    
    /// Revokes the `Refresh Token` from the Redis database.
    func revokeRefreshToken(_ refreshTokenID: String, _ result: RefreshTokenGetResult) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        payload.is_active = false
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    func revokeAllRefreshTokens(_ authID: String) async {
        if let auth = await getAuthWithTTL(authID) {
            for refreshTokenID in auth.payload.refresh_token_ids {
                if let refreshToken = await getRefreshTokenWithTTL(refreshTokenID), refreshToken.payload.is_active {
                    await revokeRefreshToken(refreshTokenID, refreshToken)
                }
            }
        }
    }
    
    func revokeAllRefreshTokens(_ auth: Auth) async {
        for refreshTokenID in auth.refresh_token_ids {
            if let refreshToken = await getRefreshTokenWithTTL(refreshTokenID), refreshToken.payload.is_active {
                await revokeRefreshToken(refreshTokenID, refreshToken)
            }
        }
    }
    
    /// Deletes the `Refresh Token` in the Redis database.
    func deleteRefreshToken(_ refreshTokenID: String) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        await self.app.redis.drop(key)
    }
    
    /// Delete all `Refresh Token`s in the Redis database.
    func deleteAllRefreshTokens(_ auth: Auth) async {
        var keys = [RedisKey]()
        for refreshTokenID in auth.refresh_token_ids {
            let key = refreshTokenRedisBucket(refreshTokenID)
            keys.append(key)
        }
        await self.app.redis.drop(keys)
    }
    
    func deleteAllRefreshTokens(_ authID: String) async {
        if let auth = await getAuth(authID) {
            var keys = [RedisKey]()
            for refreshTokenID in auth.refresh_token_ids {
                let key = refreshTokenRedisBucket(refreshTokenID)
                keys.append(key)
            }
            await self.app.redis.drop(keys)
        }
    }
    
    /// Updates the `Refresh Token Inactivity Expiration` from the Redis database.
    /// If the `TTL` value cannot be supplied, this method will automatically
    /// get the `TTL` value from the database. Performs extra task.
    func updateRefreshTokenInactivity(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var result = try await self.app.redis.getWithTTL(key, asJSON: RefreshToken.self)
        let day = TimeInterval(TTL.inactivity)
        let date = Date().addingTimeInterval(day)
        let timeinterval = date.timeIntervalSince1970
        let inactivityEXP = Int(timeinterval)
        result.payload.inactivity_exp = inactivityEXP
        try await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
    }
    
    /// Updates the `Refresh Token Inactivity Expiration` from the Redis database.
    func updateRefreshTokenInactivity(_ refreshTokenID: String, _ result: RefreshTokenGetResult) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        let day = TimeInterval(TTL.inactivity)
        let date = Date().addingTimeInterval(day)
        let timeinterval = date.timeIntervalSince1970
        let inactivityEXP = Int(timeinterval)
        payload.inactivity_exp = inactivityEXP
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    func getAllRefreshTokenIDsFromAuth(_ authID: String) async throws -> [String] {
        let key = authRedisBucket(authID)
        let auth = try await self.app.redis.get(key, asJSON: Auth.self)
        guard let auth else { return [] }
        return auth.refresh_token_ids
    }
}
