
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

struct UserToken: Codable {
    let token: String
    let jwtID: String
}

struct UserTokens: Codable {
    let refreshToken: UserToken
    let accessToken: UserToken
    
    init(_ refreshToken: UserToken, _ accessToken: UserToken) {
        self.refreshToken = refreshToken
        self.accessToken = accessToken
    }
}

final class TokenJWTHelper {
    public static let shared = TokenJWTHelper()
    
    public func generateRefreshToken(userID: String, _ req: Request) throws -> UserToken {
        let jti = UUID().uuidString
        let refreshTokenPayload = TokenClaims.V1(
            userID: userID,
            token: .refresh,
            jwtID: jti,
            expiresIn: 2_419_000)
        
        let refreshToken = try req.jwt.sign(refreshTokenPayload, kid: .private)
        return .init(token: refreshToken, jwtID: jti)
    }
    
    public func generateAccessToken(userID: String, refreshTokenID: String, _ req: Request) throws -> UserToken {
        let jti = UUID().uuidString
        let accessTokenPayload = TokenClaims.V1(
            userID: userID,
            token: .access,
            refreshTokenID: refreshTokenID,
            jwtID: jti,
            expiresIn: 1800)
        let accessToken = try req.jwt.sign(accessTokenPayload, kid: .private)
        return .init(token: accessToken, jwtID: jti)
    }
    
    public func generateTokens(userID: String, _ req: Request) throws -> UserTokens {
        let refreshToken = try generateRefreshToken(userID: userID, req)
        let accessToken = try generateAccessToken(userID: userID, refreshTokenID: refreshToken.jwtID, req)
        
        return .init(refreshToken, accessToken)
    }
    
    public func addTokensToBucket() {
        
    }
}
