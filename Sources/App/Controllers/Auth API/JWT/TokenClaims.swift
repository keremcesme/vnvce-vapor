
import Vapor
import JWT

final class TokenClaims {
    
    enum TokenType: String, Codable {
        case access = "access"
        case refresh = "refresh"
    }
    
    struct V1: Content, JWTPayload, Authenticatable {
        
        let userID: String
        let tokenType: TokenType
        let refreshTokenID: String?
        
        let iss: IssuerClaim
        let aud: AudienceClaim
        let jti: IDClaim
        let iad: IssuedAtClaim
        let exp: ExpirationClaim
        
        init(userID: String, token type: TokenType, refreshTokenID: String? = nil, jwtID: String, expiresIn: TimeInterval) {
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
        
        private enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case tokenType = "token_type"
            case refreshTokenID = "refresh_token_id"
            case iss
            case aud
            case jti
            case iad
            case exp
            
        }
    }
    
}

struct RedisTokenPayloadOLD: Codable {
    let isActive: Bool
    let stored: TimeInterval
    let ttl: TimeInterval
}

