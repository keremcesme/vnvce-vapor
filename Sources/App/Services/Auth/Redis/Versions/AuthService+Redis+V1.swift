
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
    typealias RefreshTokenGetResult = Redis.GetResult.V1<RefreshToken>
    
    /// Store `Refresh Token` to Redis database.
    func addRefreshToken(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = RefreshToken()
        let ttl = TTL.refreshToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Get `Refresh Token` from Redis database.
    func getRefreshToken(_ refreshTokenID: String) async throws -> RefreshTokenGetResult {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let payload = try await self.app.redis.get(key, asJSON: RefreshToken.self)
        guard let payload else { return .notFound(.refreshTokenNotFound) }
        let ttl = try await self.app.redis.getTTL(key)
        return .success(.init(payload, ttl: ttl))
    }
    
    /// Revokes the `Refresh Token` from the Redis database.
    /// If the `TTL` value cannot be supplied, this method will automatically
    /// get the `TTL` value from the database. Performs extra task.
    func revokeRefreshToken(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var result = try await self.app.redis.getWithTTL(key, asJSON: RefreshToken.self)
        result.payload.is_active = false
        try await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
    }
    
    /// Revokes the `Refresh Token` from the Redis database.
    func revokeRefreshToken(_ refreshTokenID: String, _ result: RedisGetResult<RefreshToken>) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        payload.is_active = false
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    /// Deletes the `Refresh Token` in the Redis database.
    func deleteRefreshToken(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        try await self.app.redis.drop(key)
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
    func updateRefreshTokenInactivity(_ refreshTokenID: String, _ result: RedisGetResult<RefreshToken>) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        var payload = result.payload
        let day = TimeInterval(TTL.inactivity)
        let date = Date().addingTimeInterval(day)
        let timeinterval = date.timeIntervalSince1970
        let inactivityEXP = Int(timeinterval)
        payload.inactivity_exp = inactivityEXP
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    // MARK: - ACCESS TOKEN -
    typealias AccessToken = Redis.AccessToken.V1
    typealias AccessTokenGetResult = Redis.GetResult.V1<AccessToken>
    
    /// Store `Access Token` to Redis database.
    func addAccessToken(_ accessTokenID: String) async throws {
        let key = refreshTokenRedisBucket(accessTokenID)
        let payload = AccessToken()
        let ttl = TTL.refreshToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    /// Get `Access Token` from Redis database.
    func getAccessToken(_ accessTokenID: String) async throws -> AccessTokenGetResult {
        let key = accessTokenRedisBucket(accessTokenID)
        let payload = try await self.app.redis.get(key, asJSON: AccessToken.self)
        guard let payload else { return .notFound(.accessTokenNotFound) }
        let ttl = try await self.app.redis.getTTL(key)
        return .success(.init(payload, ttl: ttl))
    }
    
    /// Revokes the `Access Token` from the Redis database.
    /// If the `TTL` value cannot be supplied, this method will automatically
    /// get the `TTL` value from the database. Performs extra task.
    func revokeAccessToken(_ accessTokenID: String) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        var result = try await self.app.redis.getWithTTL(key, asJSON: AccessToken.self)
        
        result.payload.is_active = false
        try await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
    }
    
    /// Revokes the `Access Token` from the Redis database.
    func revokeAccessToken(_ accessTokenID: String, _ result: RedisGetResult<AccessToken>) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        var payload = result.payload
        payload.is_active = false
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: result.ttl)
    }
    
    /// Deletes the `Access Token` in the Redis database.
    func deleteAccessToken(_ accessTokenID: String) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        try await self.app.redis.drop(key)
    }
    
    // MARK: - AUTH TOKEN -
    typealias AuthToken = Redis.AuthToken.V1
    typealias AuthTokenGetResult = Redis.GetResult.V1<AuthToken>
    
    /// Store `Auth Token` to Redis database.
    func addAuthToken(_ userID: String, _ clientID: String, _ clientOS: String, _ codeChallenge: String, _ refreshTokenID: String, _ authTokenID: String) async throws {
        let key = authTokenRedisBucket(authTokenID)
        let payload = AuthToken(userID, clientID, clientOS, codeChallenge, [refreshTokenID])
        let ttl = TTL.authToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    func addRefreshTokenIDtoAuthToken(_ authTokenID: String, _ refreshTokenID: String) async throws {
        let key = authTokenRedisBucket(authTokenID)
        let authTokenResult = try await getAuthToken(authTokenID)
        switch authTokenResult {
        case var .success(result):
            result.payload.refresh_token_ids.append(refreshTokenID)
            try await self.app.redis.setex(key, toJSON: result.payload, expirationInSeconds: result.ttl)
        case let .notFound(error):
            throw error
        }
    }
    
    /// Get `Auth Token` from Redis database.
    func getAuthToken(_ authTokenID: String) async throws -> AuthTokenGetResult {
        let key = authTokenRedisBucket(authTokenID)
        let payload = try await self.app.redis.get(key, asJSON: AuthToken.self)
        guard let payload else { return .notFound(.authTokenNotFound) }
        let ttl = try await self.app.redis.getTTL(key)
        return .success(.init(payload, ttl: ttl))
    }
    
    // MARK: - USER -
    typealias User = Redis.User.V1
    typealias UserAuthTokenIDsGetResult = Redis.UserAuthTokenIDsGetResult.V1
    
    /// Adds a new `authTokenID` to the user's key `auth_token_ids` in the Redis database.
    func setLoggedIn(_ userID: String, _ authTokenID: String) async throws {
        let key = userRedisBucket(userID)
        let authTokenIDsResult = try await getAuthTokenIDsFromUser(userID)
        switch authTokenIDsResult {
        case var .success(authTokenIDs):
            authTokenIDs.append(authTokenID)
            let payload = User(authTokenIDs)
            try await self.app.redis.set(key, toJSON: payload)
        case .notFound:
            let payload = User([authTokenID])
            try await self.app.redis.set(key, toJSON: payload)
        }
    }
    
    /// Deletes a `authTokenID` in the `auth_token_ids` key in the user's Redis database.
    /// This method also acts as a logout.
    func removeAuthTokenIDFromUser(_ userID: String, _ authTokenID: String) async throws {
        let key = userRedisBucket(userID)
        let authTokenIDsResult = try await getAuthTokenIDsFromUser(userID)
        switch authTokenIDsResult {
        case var .success(authTokenIDs):
            if let index = authTokenIDs.firstIndex(where: {$0 == authTokenID}) {
                authTokenIDs.remove(at: index)
                let payload = User(authTokenIDs)
                try await self.app.redis.set(key, toJSON: payload)
            }
        case .notFound: ()
        }
    }
    
    /// Returns all `authTokenID`s of a user from the Redis database.
    func getAuthTokenIDsFromUser(_ userID: String) async throws -> UserAuthTokenIDsGetResult {
        let key = userRedisBucket(userID)
        let payload = try await self.app.redis.get(key, asJSON: User.self)
        guard let payload else { return .notFound }
        return .success(.init(payload.auth_token_ids))
    }
    
    /// Deletes all `authTokenID`s of the user.
    /// This method terminates all user sessions.
    func deleteAllAuthTokenIDsFromUser(_ userID: String) async throws {
        let key = userRedisBucket(userID)
        try await self.app.redis.drop(key)
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
    
    private func authTokenRedisBucket(_ authTokenID: String) -> RedisKey {
        .init(Bucket.authToken + ":" + authTokenID)
    }
    
    private func userRedisBucket(_ userID: String) -> RedisKey {
        .init(Bucket.user + ":" + userID)
    }
    
    private func phoneNumbersRedisBucket(_ phoneNumber: String) -> RedisKey {
        .init(Bucket.phoneNumber + ":" + phoneNumber)
    }
    
    
}
