
import Vapor
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

extension AuthService.Redis {
    public struct V1 {
        public let app: Application
        init(_ app: Application) {
            self.app = app
        }
    }
}

public extension AuthService.Redis.V1 {
    
    // MARK: - REFRESH TOKEN -
    typealias RefreshToken = Redis.RefreshToken.V1
    typealias RefreshTokenGetResult = RedisGetResult<RefreshToken>
    
    /// Store `Refresh Token` to Redis database.
    func addRefreshToken(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = RefreshToken()
        let ttl = TTL.refreshToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
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
    
    /// Revokes the `Refresh Token` from the Redis database.
    func revokeRefreshToken(_ refreshTokenID: String, _ result: RefreshTokenGetResult) async {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        payload.is_active = false
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    /// Revoke all `Refresh Token`s from user's the Redis database.
    func revokeAllRefreshTokensFromUser(_ userID: String) async throws {
        let authIDs = try await getAuthIDsFromUser(userID)
        for authID in authIDs {
            let refreshTokenIDs = try await getAllRefreshTokenIDsFromAuth(authID)
            for refreshTokenID in refreshTokenIDs {
                if let refreshToken = await getRefreshTokenWithTTL(refreshTokenID) {
                    try await revokeRefreshToken(refreshTokenID, refreshToken)
                }
            }
        }
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
    func updateRefreshTokenInactivity(_ refreshTokenID: String, _ result: RefreshTokenGetResult) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        let day = TimeInterval(TTL.inactivity)
        let date = Date().addingTimeInterval(day)
        let timeinterval = date.timeIntervalSince1970
        let inactivityEXP = Int(timeinterval)
        payload.inactivity_exp = inactivityEXP
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    func getAllRefreshTokenIDsFromAuth(_ authID: String) async throws -> [String] {
        let key = authRedisBucket(authID)
        let auth = try await self.app.redis.get(key, asJSON: Auth.self)
        guard let auth else { return [] }
        return auth.refresh_token_ids
    }
    
    
    
    // MARK: - ACCESS TOKEN -
    typealias AccessToken = Redis.AccessToken.V1
    typealias AccessTokenGetResult = RedisGetResult<AccessToken>
    
    /// Store `Access Token` to Redis database.
    func addAccessToken(_ accessTokenID: String) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        let payload = AccessToken()
        let ttl = TTL.accessToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
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
    func revokeAccessToken(_ accessTokenID: String, _ result: AccessTokenGetResult) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        var payload = result.payload
        payload.is_active = false
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    /// Deletes the `Access Token` in the Redis database.
    func deleteAccessToken(_ accessTokenID: String) async {
        let key = accessTokenRedisBucket(accessTokenID)
        await self.app.redis.drop(key)
    }
    
    // MARK: - AUTH  -
    typealias Auth = Redis.Auth.V1
    typealias AuthGetResult = RedisGetResult<Auth>
    
    /// Store `Auth` to Redis database.
    func addAuth(_ userID: String, _ clientID: String, _ clientOS: String, _ codeChallenge: String, _ refreshTokenID: String? = nil, _ authID: String) async throws {
        let key = authRedisBucket(authID)
        let refreshTokenIDs = refreshTokenID == nil ? [] : [refreshTokenID!]
        let payload = Auth(userID, clientID, clientOS, codeChallenge, false, refreshTokenIDs)
        let ttl = TTL.authToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Adds a new `Refresh Token` to the auth's key `refrsh_token_ids` in the Redis database.
    func addRefreshTokenIDtoAuth(_ authID: String, _ refreshTokenID: String) async throws {
        let key = authRedisBucket(authID)
        if var auth = try await getAuthWithTTL(authID) {
            auth.payload.refresh_token_ids.append(refreshTokenID)
            try await self.app.redis.setex(key, toJSON: auth.payload, expirationInSeconds: auth.ttl)
        }
    }
    
    func setAuthVerified(_ authID: String) async throws {
        let key = authRedisBucket(authID)
        if var auth = try await getAuthWithTTL(authID) {
            auth.payload.is_verified = true
            try await self.app.redis.setex(key, toJSON: auth.payload, expirationInSeconds: auth.ttl)
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
    
    
    
    func deleteAuth(_ authID: String) async {
        let key = authRedisBucket(authID)
        await self.app.redis.drop(key)
    }
    
    func deleteAllAuths(_ userID: String) async {
        if let user = await getUser(userID) {
            var keys = [RedisKey]()
            for authIDs in user.auth_token_ids {
                let key = authRedisBucket(authIDs)
                keys.append(key)
            }
            await self.app.redis.drop(keys)
        }
    }
    
    // MARK: - USER -
    typealias User = Redis.User.V1
    
    /// Adds a new `authTokenID` to the user's key `auth_token_ids` in the Redis database.
    func setLoggedIn(_ userID: String, _ authID: String) async throws {
        let key = userRedisBucket(userID)
        var authIDs = try await getAuthIDsFromUser(userID)
        authIDs.append(authID)
        let payload = User(authIDs)
        try await self.app.redis.set(key, toJSON: payload)
    }
    
    func getUser(_ userID: String) async -> User? {
        let key = userRedisBucket(userID)
        let user = try? await self.app.redis.get(key, asJSON: User.self)
        return user
    }
    
    /// Deletes a `authTokenID` in the `auth_token_ids` key in the user's Redis database.
    /// This method also acts as a logout.
    func removeAuthTokenIDFromUser(_ userID: String, _ authID: String) async throws {
        let key = userRedisBucket(userID)
        var authIDs = try await getAuthIDsFromUser(userID)
        if let index = authIDs.firstIndex(where: {$0 == authID}) {
            authIDs.remove(at: index)
            let payload = User(authIDs)
            try await self.app.redis.set(key, toJSON: payload)
        }
    }
    
    /// Returns all `authTokenID`s of a user from the Redis database.
    func getAuthIDsFromUser(_ userID: String) async throws -> [String] {
        let key = userRedisBucket(userID)
        let payload = try await self.app.redis.get(key, asJSON: User.self)
        guard let payload else { return [] }
        return payload.auth_token_ids
    }
    
    /// Deletes all `authTokenID`s of the user.
    /// This method terminates all user sessions.
    func deleteAllAuthTokenIDsFromUser(_ userID: String) async {
        let key = userRedisBucket(userID)
        await self.app.redis.drop(key)
    }
    
    func deleteUser(_ userID: String) async {
        let key = userRedisBucket(userID)
        await self.app.redis.drop(key)
    }
}

fileprivate typealias Bucket = Redis.Bucket.V1
extension AuthService.Redis.V1 {
    private func accessTokenRedisBucket(_ accessTokenID: String) -> RedisKey {
        .init(Bucket.accessToken + ":" + accessTokenID)
    }
    
    private func refreshTokenRedisBucket(_ refreshTokenID: String) -> RedisKey {
        .init(Bucket.refreshToken + ":" + refreshTokenID)
    }
    
    private func authRedisBucket(_ authID: String) -> RedisKey {
        .init(Bucket.auth + ":" + authID)
    }
    
    private func userRedisBucket(_ userID: String) -> RedisKey {
        .init(Bucket.user + ":" + userID)
    }
    
    private func phoneNumbersRedisBucket(_ phoneNumber: String) -> RedisKey {
        .init(Bucket.phoneNumber + ":" + phoneNumber)
    }
}
