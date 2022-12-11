
import Vapor
import JWT
import JWTDecode
import Redis
import RediStack

final class JWTHelper {
    public struct V1 {
        public let jwt: Request.JWT
        public let plugin: JWTPlugin.V1
        
        public init(_ req: Request) {
            self.jwt = req.jwt
            self.plugin = .init(req.redis)
        }
    }
}
