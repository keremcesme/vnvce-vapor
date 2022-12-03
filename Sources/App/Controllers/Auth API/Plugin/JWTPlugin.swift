
import Vapor
import Redis

final class JWTPlugin {
    public struct V1 {
        public let redis: Request.Redis
        
        public init(_ redis: Request.Redis) {
            self.redis = redis
        }
    }
}
