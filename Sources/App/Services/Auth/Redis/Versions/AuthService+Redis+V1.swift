
import Vapor
import Redis
import RediStack

fileprivate typealias Bucket = RedisBucket.V1
fileprivate typealias TTL = RedisTTL.V1
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
    func addTokensToBucket(tokens: FreshTokens.V1, clientID: String, authCodeID: String) async throws {
        let refreshTokenID = tokens.refreshToken.jwtID
        let accessTokenID = tokens.accessToken.jwtID
        try await self.addTokenToBucket(tokenID: refreshTokenID, to: .refreshToken(authCodeID))
        try await self.addTokenToBucket(tokenID: accessTokenID, to: .accessToken(refreshTokenID))
    }
    
    func addTokenToBucket(tokenID: String, to bucket: RedisAddBucket.V1) async throws {
        switch bucket {
        case let .accessToken(refreshTokenID):
            try await addAccessTokenToBucket(tokenID, refreshTokenID)
        case let .refreshToken(authCodeID):
            try await addRefreshTokenToBucket(tokenID, authCodeID)
        }
    }
    
    func getTokenFromBucket(jwtID: String, from bucket: RedisGetBucket.V1) async throws -> RedisGetResult.V1 {
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
    
//    func getRefreshTokensForUser(_ userID: String) async throws -> RedisGetUserRefreshTokensResult.V1 {
//        let key = userRedisBucket(userID)
//        let payload = try await self.app.redis.get(key, asJSON: RedisUserPayload.V1.self)
//
//        guard let payload else {
//            return .notFound
//        }
//
//        return .success(payload)
//    }
    
//    func revokeTokenFromBucket(_ jwtID: String, payload: RedisTokenPayload.V1, from bucket: RedisRevokeBucket.V1) async throws {
//        switch bucket {
//        case .accessToken:
//            try await revokeAccessTokenFromBucket(jwtID, payload: payload)
//        case let .refreshToken(user):
//            try await revokeRefreshTokenFromBucket(jwtID, payload: payload)
//        }
//    }
}

// MARK: User
public extension AuthService.Redis.V1 {
    func setLoggedInUserToBucket(_ userID: String, refresh jwtID: String, currentTokens: [String] = []) async throws {
        let key = userRedisBucket(userID)
        var tokens = currentTokens
        tokens.append(jwtID)
        let payload = RedisUserPayload.V1(authCodes: tokens)
        let exp = TTL.refreshToken
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    func deleteRefreshTokenFromUserBucket(_ token: String, userID: String, payload: RedisUserPayload.V1) async throws {
        let key = userRedisBucket(userID)
        var payload = payload
        guard let inx = payload.authCodes.firstIndex(where: {$0 == token}) else {
            return
        }
        payload.authCodes.remove(at: inx)
        
        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
        
        guard let duration else {return}
        
        let second = duration / 1_000_000_000
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
    }
}

// MARK: Auth Code
public extension AuthService.Redis.V1 {
    func addAuthCodeToBucket(userID: String, challenge: String, clientID: String, _ jwtID: String) async throws {
        let key = authCodeRedisBucket(jwtID)
        let payload = RedisAuthCodePayload.V1(userID: userID, codeChallenge: challenge, clientID: clientID)
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
    private func addAccessTokenToBucket(_ accessTokenID: String, _ refreshTokenID: String) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        let exp = TTL.accessToken
        let payload = RedisAccessTokenPayload.V1(refreshTokenID)
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getAccessTokenFromBucket(_ accessTokenID: String) async throws -> RedisGetResult.V1 {
        let key = accessTokenRedisBucket(accessTokenID)
        let payload = try await self.app.redis.get(key, asJSON: RedisAccessTokenPayload.V1.self)
        
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
    
    
    private func deleteAccessTokenFromBucket(_ accessTokenID: String) async throws {
        let key = accessTokenRedisBucket(accessTokenID)
        try await self.app.redis.drop(key)
    }
    
//    private func revokeAccessTokenFromBucket(_ accessTokenID: String, payload: RedisAccessTokenPayload.V1) async throws {
//        let key = accessTokenRedisBucket(accessTokenID)
//
//        var payload = payload
//        payload.isActive = false
//
//
//        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
//
//        guard let duration else {return}
//
//        let second = duration / 1_000_000_000
//        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
//    }
}

// MARK: Refresh Token
private extension AuthService.Redis.V1 {
    private func addRefreshTokenToBucket(_ refreshTokenID: String, _ authCodeID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        let exp = TTL.refreshToken
        let payload = RedisRefreshTokenPayload.V1(authCodeID)
        
        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: exp)
    }
    
    private func getRefreshTokenFromBucket(_ jwtID: String) async throws -> RedisGetResult.V1 {
        let key = refreshTokenRedisBucket(jwtID)
        let payload = try await self.app.redis.get(key, asJSON: RedisRefreshTokenPayload.V1.self)
        
        guard let payload else {
            return .notFound
        }
        
        return .success(payload)
    }
    
    private func deleteRefreshTokenFromBucket(_ refreshTokenID: String) async throws {
        let key = refreshTokenRedisBucket(refreshTokenID)
        try await self.app.redis.drop(key)
    }
    
//    private func revokeRefreshTokenFromBucket(_ refreshTokenID: String, payload: RedisRefreshTokenPayload.V1) async throws {
//        let key = refreshTokenRedisBucket(refreshTokenID)
//
//        var payload = payload
//        payload.isActive = false
//
//        let duration = try await self.app.redis.ttl(key).get().timeAmount?.nanoseconds
//
//        guard let duration else {return}
//
//        let second = duration / 1_000_000_000
//        try await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: Int(second))
//
//    }
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
    
    private func phoneNumbersRedisBucket(_ phoneNumber: String) -> RedisKey {
        .init(Bucket.phoneNumber + ":" + phoneNumber)
    }
    
    private func authCodeRedisBucket(_ jwtID: String) -> RedisKey {
        .init(Bucket.authCode + ":" + jwtID)
    }
}
