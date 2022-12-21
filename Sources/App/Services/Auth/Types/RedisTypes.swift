
import Foundation
import Vapor

public protocol RedisModel: Codable {}

public final class Redis {
    
    // MARK: TTL
    public final class TTL {
        public enum V1 {
            static let otp = 60                         // 1 min
            static let accessToken = 60 * 10            // 10 min
            static let inactivity = 60 * 60 * 24 * 7    // 7 day
            static let refreshToken = 60 * 60 * 24 * 30 // 30 day
            static let authToken = 60 * 60 * 24 * 45    // 45 day
        }
    }
    
    // MARK: OTP
    public final class OTP {
        public struct V1: RedisModel {
            public let encryptedCode: String
            public let otpID: String
            public let clientID: String
            public let clientOS: String
            public let userID: String?
            public init(encryptedCode: String, otpID: String, clientID: String, clientOS: String, userID: String? = nil) {
                self.encryptedCode = encryptedCode
                self.otpID = otpID
                self.clientID = clientID
                self.clientOS = clientOS
                self.userID = userID
            }
        }
    }
    
    // MARK: Access Token
    public final class AccessToken {
        public struct V1: RedisModel {
            public var is_active: Bool
            public init(_ isActive: Bool = true) {
                self.is_active = isActive
            }
            public func verify() -> Bool {
                return is_active
            }
        }
    }
    
    // MARK: Refresh Token
    public final class RefreshToken {
        public struct V1: RedisModel {
            public var is_active: Bool
            public var inactivity_exp: Int
            public init(_ isActive: Bool = true, inactivityEXP: Int? = nil) {
                self.is_active = isActive
                if let inactivityEXP {
                    self.inactivity_exp = inactivityEXP
                } else {
                    let day = TimeInterval(TTL.V1.inactivity)
                    let date = Date().addingTimeInterval(day)
                    let timeinterval = date.timeIntervalSince1970
                    let inactivityEXP = Int(timeinterval)
                    self.inactivity_exp = inactivityEXP
                }
            }
            public func verify() -> Bool {
                return is_active
            }
        }
    }
    
    // MARK: Auth
    public final class Auth {
        public struct V1: RedisModel {
            public var code_challenge: String
            public var is_verified: Bool
            public var refresh_token_ids: [String]
            public init(
                challenge codeChallenge: String,
                isVerified: Bool = false,
                rtIDs refreshTokenIDs: [String] = []
            ) {
                self.code_challenge = codeChallenge
                self.is_verified = isVerified
                self.refresh_token_ids = refreshTokenIDs
            }
        }
    }
    
    // MARK: GET Result
    public final class GetResult {
        public enum V1<R: RedisModel> {
            case success(RedisGetResult<R>)
            case notFound(Error)
        }
    }
    
    // MARK: Buckets
    public final class Bucket {
        public enum V1 {
            static let accessToken = "access_tokens"
            static let refreshToken = "refresh_tokens"
            static let auth = "auths"
            
            static let otp = "otps"
            static let reservedUsername = "reserved_usernames"
        }
    }

    // MARK: Error
    public typealias Error = RedisError.V1
}

public final class RedisError {
    public enum V1: String, Error {
        case accessTokenNotFound
        case refreshTokenNotFound
        case authNotFound
        case userNotFound
        case noTTL
        case keyNotFound
    }
}
