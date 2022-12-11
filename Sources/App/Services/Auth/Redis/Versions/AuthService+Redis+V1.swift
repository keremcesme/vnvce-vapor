
import Vapor
import Redis
import RediStack

fileprivate typealias Bucket = RedisBucket.V1
fileprivate typealias TTL = RedisTokenTTL.V1
fileprivate typealias Error = RedisError.V1

extension AuthService.Redis {
    public struct V1 {
        public let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

// MARK: Tokens
public extension AuthService.Redis.V1 {
    func addTokensToBucket(tokens: FreshTokens.V1, clientID: String) async throws {
        let refreshTokenID = tokens.refreshToken.jwtID
        let accessTokenID = tokens.accessToken.jwtID
        try await self.addTokenToBucket(jwtID: refreshTokenID, to: .refreshToken(clientID))
        try await self.addTokenToBucket(jwtID: accessTokenID, to: .accessToken)
    }
    
    func addTokenToBucket(jwtID: String, to bucket: RedisAddBucket.V1) async throws {
        switch bucket {
        case .accessToken:
            try await addAccessTokenToBucket(jwtID)
        case let .refreshToken(clientID):
            try await addRefreshTokenToBucket(jwtID, clientID: clientID)
        }
    }
    
    func getTokenFromBucket(jwtID: String, from bucket: RedisGetBucket.V1) async throws -> RedisGetTokenResult.V1 {
        switch bucket {
        case .accessToken:
            return try await getAccessTokenFromBucket(jwtID)
        case .refreshToken:
            return try await getRefreshTokenFromBucket(jwtID)
        }
    }
    
    func deleteTokenFromBucket(jwtID: String, from bucket: RedisGetBucket.V1) async throws {
        switch bucket {
        case .accessToken:
            try await deleteAccessTokenFromBucket(jwtID)
        case .refreshToken:
            try await deleteRefreshTokenFromBucket(jwtID)
        }
    }
    
    func getRefreshTokensForUser(_ userID: String) async throws -> RedisGetUserRefreshTokensResult.V1 {
        let key = userRedisBucket(userID)
        let payload = try await self.app.redis.get(key, asJSON: RedisUserPayload.V1.self)
        
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
    
    func revokeTokenFromBucket(_ jwtID: String, payload: RedisTokenPayload.V1, from bucket: RedisRevokeBucket.V1) async throws {
        switch bucket {
        case .accessToken:
            try await revokeAccessTokenFromBucket(jwtID, payload: payload)
        case let .refreshToken(user):
            try await revokeRefreshTokenFromBucket(jwtID, payload: payload)
        }
    }
}

// MARK: User
public extension AuthService.Redis.V1 {
    func setLoggedInUserToBucket(_ userID: String, refresh jwtID: String, currentTokens: [String] = []) async throws {
        let key = userRedisBucket(userID)
        var tokens = currentTokens
        tokens.append(jwtID)
        let payload = RedisUserPayload.V1(refreshTokens: tokens)
        let exp = TTL.refreshToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    func deleteRefreshTokenFromUserBucket(_ token: String, userID: String, payload: RedisUserPayload.V1) async throws {
        let key = userRedisBucket(userID)
        var payload = payload
        guard let inx = payload.refreshTokens.firstIndex(where: {$0 == token}) else {
            return
        }
        payload.refreshTokens.remove(at: inx)
        
        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
        
        guard let duration else {return}
        
        let second = duration / 1_000_000_000
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
    }
}

// MARK: Auth Code
public extension AuthService.Redis.V1 {
    func addAuthCodeToBucket(challenge: String, clientID: String, _ jwtID: String) async throws {
        let key = authCodeRedisBucket(jwtID)
        let payload = RedisAuthCodePayload.V1(codeChallenge: challenge, clientID: clientID)
        try await self.app.redis.set(key, toJSON: payload)
    }
    
    func getAuthCodeFromBucket(_ jwtID: String) async throws -> RedisGetAuthCodeResult.V1 {
        let key = authCodeRedisBucket(jwtID)
        let payload = try await self.app.redis.get(key, asJSON: RedisAuthCodePayload.V1.self)
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
}

// MARK: Access Token
private extension AuthService.Redis.V1 {
    private func addAccessTokenToBucket(_ jwtID: String) async throws {
        let key = accessTokenRedisBucket(jwtID)
        let exp = TTL.accessToken
        let payload = RedisTokenPayload.V1()
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getAccessTokenFromBucket(_ jwtID: String) async throws -> RedisGetTokenResult.V1 {
        let key = accessTokenRedisBucket(jwtID)
        let payload = try await self.app.redis.get(key, asJSON: RedisTokenPayload.V1.self)
        
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
    
    
    private func deleteAccessTokenFromBucket(_ jwtID: String) async throws {
        let key = accessTokenRedisBucket(jwtID)
        try await self.app.redis.drop(key)
    }
    
    private func revokeAccessTokenFromBucket(_ jwtID: String, payload: RedisTokenPayload.V1) async throws {
        let key = accessTokenRedisBucket(jwtID)
        
        var payload = payload
        payload.isActive = false
        
        
        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
        
        guard let duration else {return}
        
        let second = duration / 1_000_000_000
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
    }
}

// MARK: Refresh Token
private extension AuthService.Redis.V1 {
    private func addRefreshTokenToBucket(_ jwtID: String, clientID: String) async throws {
        let key = refreshTokenRedisBucket(jwtID)
        let exp = TTL.refreshToken
        let payload = RedisTokenPayload.V1(clientID: clientID)
        
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getRefreshTokenFromBucket(_ jwtID: String) async throws -> RedisGetTokenResult.V1 {
        let key = refreshTokenRedisBucket(jwtID)
        let payload = try await self.app.redis.get(key, asJSON: RedisTokenPayload.V1.self)
        
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
    
    private func deleteRefreshTokenFromBucket(_ jwtID: String) async throws {
        let key = refreshTokenRedisBucket(jwtID)
        try await self.app.redis.drop(key)
    }
    
    private func revokeRefreshTokenFromBucket(_ jwtID: String, payload: RedisTokenPayload.V1) async throws {
        let key = refreshTokenRedisBucket(jwtID)
        
        var payload = payload
        payload.isActive = false
        
        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
        
        guard let duration else {return}
        
        let second = duration / 1_000_000_000
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
        
    }
}

extension AuthService.Redis.V1 {
    private func accessTokenRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.accessToken + ":" + jwtID)
    }
    
    private func refreshTokenRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.refreshToken + ":" + jwtID)
    }
    
    private func userRedisBucket(_ userID: String) -> RedisKey {
        .init(Bucket.user + ":" + userID)
    }
    
    private func sessionRedisBucket(_ sessionID: String) -> RedisKey {
        .init(Bucket.session + ":" + sessionID)
    }
    
    private func phoneNumbersRedisBucket(_ phoneNumber: String) -> RedisKey {
        .init(Bucket.phoneNumber + ":" + phoneNumber)
    }
    
    private func authCodeRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.authCode + ":" + jwtID)
    }
}
