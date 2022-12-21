
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

public extension AuthService.Redis.V1 {
    // MARK: - AUTH  -
    typealias Auth = Redis.Auth.V1
    typealias AuthGetResult = RedisGetResult<Auth>
    
    /// Store `Auth` to Redis database.
    func addAuth(authID: String, challenge codeChallenge: String, rtID refreshTokenID: String? = nil) async {
        let key = authRedisBucket(authID)
        let refreshTokenIDs = refreshTokenID == nil ? [] : [refreshTokenID!]
        let payload = Auth(challenge: codeChallenge, rtIDs: refreshTokenIDs)
        let ttl = TTL.authToken
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Adds a new `Refresh Token` to the auth's key `refrsh_token_ids` in the Redis database.
    func addRefreshTokenIDtoAuth(_ authID: String, _ refreshTokenID: String) async throws {
        let key = authRedisBucket(authID)
        if var auth = try await getAuthWithTTL(authID) {
            auth.payload.refresh_token_ids.append(refreshTokenID)
            try await self.app.redis.setex(key, toJSON: auth.payload, expirationInSeconds: auth.ttl)
        }
    }
    
    func addRefreshTokenIDandSetVerified(id: String, result: AuthGetResult, rtID refreshTokenID: String) async {
        let key = authRedisBucket(id)
        var payload = result.payload
        payload.is_verified = true
        payload.refresh_token_ids.append(refreshTokenID)
        do {
            try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
        } catch {
            await deleteAuth(id)
        }
        
    }
    
    func addRefreshTokenIDtoAuth(id: String, result: AuthGetResult, rtID refreshTokenID: String) async {
        let key = authRedisBucket(id)
        var payload = result.payload
        payload.refresh_token_ids.append(refreshTokenID)
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    func setAuthVerified(_ authID: String) async throws {
        let key = authRedisBucket(authID)
        if var auth = try await getAuthWithTTL(authID) {
            auth.payload.is_verified = true
            try await self.app.redis.setex(key, toJSON: auth.payload, expirationInSeconds: auth.ttl)
        }
    }
    
    func setAuthVerified(id: String, _ result: AuthGetResult) async {
        let key = authRedisBucket(id)
        var payload = result.payload
        payload.is_verified = true
        do {
            try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
        } catch {
            await deleteAuth(id)
        }
    }
    
    /// Get `Auth` from Redis database.
    func getAuth(_ authID: String) async -> Auth? {
        let key = authRedisBucket(authID)
        let payload = try? await self.app.redis.get(key, asJSON: Auth.self)
        return payload
    }
    
    /// Get `Auth` with TTL from Redis database.
    func getAuthWithTTL(_ authID: String) async -> AuthGetResult? {
        let key = authRedisBucket(authID)
        let payload = try? await self.app.redis.get(key, asJSON: Auth.self)
        let ttl = try? await self.app.redis.getTTL(key)
        if let payload, let ttl {
            return .init(payload, ttl: ttl)
        } else {
            return nil
        }
    }
    
    func deleteAuthWithRefreshTokens(_ authID: String) async {
        let key = authRedisBucket(authID)
        if let auth = await getAuth(authID) {
            var keys = [RedisKey]()
            for rtID in auth.refresh_token_ids {
                let key = refreshTokenRedisBucket(rtID)
                keys.append(key)
            }
            await self.app.redis.drop(keys)
            await self.app.redis.drop(key)
        }
        
    }
    
    func deleteAuthWithRefreshTokens(_ authID: String, auth: Auth) async {
        let key = authRedisBucket(authID)
        var keys = [RedisKey]()
        for rtID in auth.refresh_token_ids {
            let key = refreshTokenRedisBucket(rtID)
            keys.append(key)
        }
        await self.app.redis.drop(keys)
        await self.app.redis.drop(key)
    }
    
    func deleteAuth(_ authID: String) async {
        let key = authRedisBucket(authID)
        await self.app.redis.drop(key)
    }
    
    func verifyAuth(authID: String, rtID: String) async -> Bool {
        let key = authRedisBucket(authID)
        guard let payload = try? await self.app.redis.get(key, asJSON: Auth.self),
                  payload.is_verified,
                  payload.refresh_token_ids.contains(rtID)
        else {
            return false
        }
        return true
    }
    
    func verifyAuth(auth: Auth, rtID: String) -> Bool {
        guard auth.is_verified,
              auth.refresh_token_ids.contains(rtID)
        else {
            return false
        }
        return true
    }
    
    
    
}
