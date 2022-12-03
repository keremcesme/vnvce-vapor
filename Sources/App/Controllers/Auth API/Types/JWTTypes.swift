
import Vapor
import JWT

final class FreshToken {
    public struct V1: Codable {
        let value: String
        let jwtID: String
    }
}

final class FreshTokens {
    public struct V1: Codable {
        let accessToken: FreshToken.V1
        let refreshToken: FreshToken.V1
        
        init(_ refreshToken: FreshToken.V1, _ accessToken: FreshToken.V1) {
            self.refreshToken = refreshToken
            self.accessToken = accessToken
        }
    }
}

final class TokenType {
    public enum V1: String, Codable {
        case access = "access"
        case refresh = "refresh"
    }
}

final class GenerateTokenType {
    public enum V1 {
        case access(_ refreshTokenID: String)
        case refresh
    }
}

final class JWTTokenTTL {
    public enum V1 {
        static let accessToken = TimeInterval(60 * 10) // 10 min
        static let refreshToken = TimeInterval(60 * 60 * 24 * 30) // 30 day
    }
}

final class TokenPayload {
    public struct V1: Content, JWTPayload, Authenticatable {
        let userID: String
        let tokenType: TokenType.V1
        let refreshTokenID: String?
        
        let iss: IssuerClaim
        let aud: AudienceClaim
        let jti: IDClaim
        let iad: IssuedAtClaim
        let exp: ExpirationClaim
        
        init(
            userID: String,
            token type: TokenType.V1,
            refreshTokenID: String? = nil,
            jwtID: String,
            expiresIn: TimeInterval
        ) {
            let date = Date()
            self.userID = userID
            self.tokenType = type
            self.refreshTokenID = refreshTokenID
            self.iss = .init(value: "api.vnvce.com")
            self.aud = .init(value: ["vnvce.com"])
            self.jti = .init(value: jwtID)
            self.iad = .init(value: date)
            self.exp = .init(value: date.addingTimeInterval(expiresIn))
        }
        
        func verify(using signer: JWTSigner) throws {
            try self.exp.verifyNotExpired()
        }
        
    }
    
    
}
