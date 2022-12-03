
import Foundation

final class RedisBucket {
    public enum V1 {
        static let user = "users"
        static let accessToken = "access_tokens"
        static let refreshToken = "refresh_tokens"
    }
}

final class RedisAddGetBucket {
    public enum V1 {
        case accessToken
        case refreshToken
    }
}

final class RedisTokenTTL {
    public enum V1 {
        static let accessToken = 60 * 10 // 10 min
        static let refreshToken = 60 * 60 * 24 * 30 // 30 day
    }
}

final class RedisTokenPayload {
    public struct V1: Codable {
        public let isActive: Bool
        public init(isActive: Bool = true) {
            self.isActive = isActive
        }
    }
}

final class RedisUserPayload {
    public struct V1: Codable {
        public let tokens: [String]
    }
}

final class RedisError {
    public enum V1: String, Error {
        case accessTokenNotFound
        case refreshTokenNotFound
        case userNotFound
    }
}
