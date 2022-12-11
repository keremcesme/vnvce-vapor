
import Foundation

final class RedisBucket {
    public enum V1 {
        static let user = "users"
        static let accessToken = "access_tokens"
        static let refreshToken = "refresh_tokens"
        static let phoneNumber = "phone_numbers"
        static let authCode = "auth_codes"
    }
}

public final class RedisGetBucket {
    public enum V1 {
        case accessToken
        case refreshToken
    }
}

public final class RedisAddBucket {
    public enum V1 {
        case accessToken(_ refreshTokenID: String)
        case refreshToken(_ authCodeID: String)
    }
}

public final class RedisRevokeBucket {
    public enum V1 {
        case accessToken
        case refreshToken(_ user: RedisUserPayload.V1?)
    }
}

final class RedisTTL {
    public enum V1 {
        static let accessToken = 60 * 10 // 10 min
        static let refreshToken = 60 * 60 * 24 * 30 // 30 day
        static let authCode = 60 * 60 * 24 * 45 // 45 day
    }
}

// MARK: Redis Payloads
// Access Token
public final class RedisAccessTokenPayload {
    public struct V1: Codable {
        public var isActive: Bool
        public var refreshTokenID: String
        public init(_ refreshTokenID: String, isActive: Bool = true) {
            self.refreshTokenID = refreshTokenID
            self.isActive = isActive
        }
    }
}

// Refresh Token
public final class RedisRefreshTokenPayload {
    public struct V1: Codable {
        public var isActive: Bool
        public var authCodeID: String
        public init(_ authCodeID: String, isActive: Bool = true) {
            self.authCodeID = authCodeID
            self.isActive = isActive
        }
    }
}

// Auth Code
public final class RedisAuthCodePayload {
    public struct V1: Codable {
        public let userID: String
        public let codeChallenge: String
        public let clientID: String
        public let refreshTokenID: String
    }
}

// User
public final class RedisUserPayload {
    public struct V1: Codable {
        public var authCodes: [String]
    }
}

public final class RedisGetResult {
    public enum V1 {
        case success(any Codable)
        case notFound
    }
}

public final class RedisGetAuthCodeResult {
    public enum V1: Codable {
        case success(RedisAuthCodePayload.V1)
        case notFound
    }
}





final class RedisError {
    public enum V1: String, Error {
        case accessTokenNotFound
        case refreshTokenNotFound
        case userNotFound
    }
}
