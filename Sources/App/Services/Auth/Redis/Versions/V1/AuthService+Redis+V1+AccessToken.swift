
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

public extension AuthService.Redis.V1 {
    // MARK: - ACCESS TOKEN -
    typealias AccessToken = Redis.AccessToken.V1
    typealias AccessTokenGetResult = RedisGetResult<AccessToken>
    
    /// Store `Access Token` to Redis database.
    func addAccessToken(_ accessTokenID: String) async {
        let key = accessTokenRedisBucket(accessTokenID)
        let payload = AccessToken()
        let ttl = TTL.accessToken
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Get `Access Token` from Redis database.
    func getAccessToken(_ accessTokenID: String) async throws -> AccessToken? {
        let key = accessTokenRedisBucket(accessTokenID)
        let accessToken = try await self.app.redis.get(key, asJSON: AccessToken.self)
        guard let accessToken else { return nil }
        return accessToken
    }
    
    /// Get `Access Token` with TTL from Redis database.
    func getAccessTokenWithTTL(_ accessTokenID: String) async throws -> AccessTokenGetResult? {
        let key = accessTokenRedisBucket(accessTokenID)
        let payload = try await self.app.redis.get(key, asJSON: AccessToken.self)
        guard let payload else { return nil }
        let ttl = try await self.app.redis.getTTL(key)
        return .init(payload, ttl: ttl)
    }
    
    /// Revokes the `Access Token` from the Redis database.
    /// If the `TTL` value cannot be supplied, this method will automatically
    /// get the `TTL` value from the database. Performs extra task.
    func revokeAccessToken(_ accessTokenID: String) async {
        let key = accessTokenRedisBucket(accessTokenID)
        if var result = try? await self.app.redis.getWithTTL(key, asJSON: AccessToken.self) {
            if result.payload.is_active {
                result.payload.is_active = false
                try? await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
            }
        }
    }
    
    /// Revokes the `Access Token` from the Redis database.
    func revokeAccessToken(_ accessTokenID: String, _ result: AccessTokenGetResult) async {
        let key = accessTokenRedisBucket(accessTokenID)
        var payload = result.payload
        payload.is_active = false
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    /// Deletes the `Access Token` in the Redis database.
    func deleteAccessToken(_ accessTokenID: String) async {
        let key = accessTokenRedisBucket(accessTokenID)
        await self.app.redis.drop(key)
    }
}
