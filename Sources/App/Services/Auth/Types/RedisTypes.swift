
import Foundation

final class RedisBucket {
    public enum V1 {
        static let user = "users"
        static let accessToken = "access_tokens"
        static let refreshToken = "refresh_tokens"
        static let session = "sessions"
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
        case accessToken
        case refreshToken(_ clientID: String)
    }
}

public final class RedisRevokeBucket {
    public enum V1 {
        case accessToken
        case refreshToken(_ user: RedisUserPayload.V1?)
    }
}

final class RedisTokenTTL {
    public enum V1 {
        static let accessToken = 60 * 10 // 10 min
        static let refreshToken = 60 * 60 * 24 * 30 // 30 day
    }
}

// MARK: Redis Payloads
// Access Token
public final class RedisAccessTokenPayload {
    public struct V1: Codable {
        public var isActive: Bool
        public init(isActive: Bool = true) {
            self.isActive = isActive
        }
    }
}

// Refresh Token
public final class RedisRefreshTokenPayload {
    public struct V1: Codable {
        public var isActive: Bool
        public let sessionID: String
        public init(isActive: Bool = true, sessionID: String) {
            self.isActive = isActive
            self.sessionID = sessionID
        }
    }
}

// Auth Code
public final class RedisAuthCodePayload {
    public struct V1: Codable {
        public let codeChallenge: String
        public let clientID: String
    }
}

// User Sessions
public final class RedisUserSessionsPayload {
    public struct V1: Codable {
        public let sessions: [String]
    }
}

public final class RedisTokenPayload {
    public struct V1: Codable {
        public var isActive: Bool
        public let clientID: String?
        
        public init(isActive: Bool = true, clientID: String? = nil) {
            self.isActive = isActive
            self.clientID = clientID
        }
    }
}

public final class RedisUserPayload {
    public struct V1: Codable {
        public var refreshTokens: [String]
    }
}

public final class RedisGetTokenResult {
    public enum V1: Codable {
        case success(RedisTokenPayload.V1)
        case notFound
    }
}

public final class RedisGetUserRefreshTokensResult {
    public enum V1: Codable {
        case success(RedisUserPayload.V1)
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
