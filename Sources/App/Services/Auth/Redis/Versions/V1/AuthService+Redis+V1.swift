
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

typealias Bucket = Redis.Bucket.V1
public extension AuthService.Redis.V1 {
    func accessTokenRedisBucket(_ accessTokenID: String) -> RedisKey {
        .init(Bucket.accessToken + ":" + accessTokenID)
    }
    
    func refreshTokenRedisBucket(_ refreshTokenID: String) -> RedisKey {
        .init(Bucket.refreshToken + ":" + refreshTokenID)
    }
    
    func authRedisBucket(_ authID: String) -> RedisKey {
        .init(Bucket.auth + ":" + authID)
    }
    
    func otpRedisBucket(_ phoneNumber: String) -> RedisKey {
        .init(Bucket.otp + ":" + phoneNumber)
    }
    
    func reservedUsernameRedisBucket(_ username: String) -> RedisKey {
        .init(Bucket.reservedUsername + ":" + username)
    }
}
