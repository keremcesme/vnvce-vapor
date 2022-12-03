
import Vapor
import JWT
import JWTDecode
import Redis
import RediStack

fileprivate typealias Bucket = RedisBucket.V1
fileprivate typealias TTL = RedisTokenTTL.V1
fileprivate typealias Error = RedisError.V1

typealias AddBucket = RedisAddGetBucket.V1
typealias GetBucket = RedisAddGetBucket.V1

extension JWTPlugin.V1 {
    
    func addTokenToBucket(jwtID: String, to bucket: AddBucket) async throws {
        switch bucket {
        case .accessToken:
            try await addAccessTokenToBucket(jwtID)
        case .refreshToken:
            try await addRefreshTokenToBucket(jwtID)
        }
    }
    
    func getTokenFromBucket(jwtID: String, from bucket: GetBucket) async throws -> Result<RedisTokenPayload.V1, RedisError.V1>{
        switch bucket {
        case .accessToken:
            return try await getAccessTokenFromBucket(jwtID)
        case .refreshToken:
            return try await getRefreshTokenFromBucket(jwtID)
        }
    }
    
    func deleteTokenFromBucket(jwtID: String, from bucket: GetBucket) async throws {
        switch bucket {
        case .accessToken:
            try await deleteAccessTokenFromBucket(jwtID)
        case .refreshToken:
            try await deleteRefreshTokenFromBucket(jwtID)
        }
    }
    
    func getRefreshTokensForUser(_ userID: String) async throws -> Result<RedisUserPayload.V1, RedisError.V1>{
        let key = usersRedisBucket(userID)
        let payload = try await self.redis.get(key, asJSON: RedisUserPayload.V1.self)
        
        guard let payload else {
            return .failure(.userNotFound)
        }
        
        return .success(payload)
    }
    
    func setLoggedInUserToBucket(_ userID: String, refresh jwtID: String, currentTokens: [String] = []) async throws {
        let key = usersRedisBucket(userID)
        var tokens = currentTokens
        tokens.append(jwtID)
        let payload = RedisUserPayload.V1(tokens: tokens)
        let exp = TTL.refreshToken
        try await self.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
}

// MARK: Access Token
private extension JWTPlugin.V1 {
    private func addAccessTokenToBucket(_ jwtID: String) async throws {
        let key = accessTokenRedisBucket(jwtID)
        let payload = RedisTokenPayload.V1()
        let exp = TTL.accessToken
        try await self.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getAccessTokenFromBucket(_ jwtID: String) async throws -> Result<RedisTokenPayload.V1, Error> {
        let key = accessTokenRedisBucket(jwtID)
        let payload = try await self.redis.get(key, asJSON: RedisTokenPayload.V1.self)
        
        guard let payload else {
            return .failure(.accessTokenNotFound)
        }
        
        return .success(payload)
    }
    
    private func deleteAccessTokenFromBucket(_ jwtID: String) async throws {
        let key = accessTokenRedisBucket(jwtID)
        try await self.redis.drop(key)
    }
}

// MARK: Refresh Token
private extension JWTPlugin.V1 {
    private func addRefreshTokenToBucket(_ jwtID: String) async throws {
        let key = refreshTokenRedisBucket(jwtID)
        let payload = RedisTokenPayload.V1()
        let exp = TTL.refreshToken
        try await self.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getRefreshTokenFromBucket(_ jwtID: String) async throws -> Result<RedisTokenPayload.V1, Error>{
        let key = refreshTokenRedisBucket(jwtID)
        let payload = try await self.redis.get(key, asJSON: RedisTokenPayload.V1.self)
        
        guard let payload else {
            return .failure(.accessTokenNotFound)
        }
        
        return .success(payload)
    }
    
    private func deleteRefreshTokenFromBucket(_ jwtID: String) async throws {
        let key = refreshTokenRedisBucket(jwtID)
        try await self.redis.drop(key)
    }
}

// MARK: Redis Buckets
extension JWTPlugin.V1 {
    private func accessTokenRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.accessToken + ":" + jwtID)
    }
    
    private func refreshTokenRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.refreshToken + ":" + jwtID)
    }
    
    private func usersRedisBucket(_ userID: String) -> RedisKey {
        .init(Bucket.user + ":" + userID)
    }
}
