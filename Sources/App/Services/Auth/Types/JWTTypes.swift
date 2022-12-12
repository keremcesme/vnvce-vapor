
import Vapor
import JWT
import VNVCECore

public typealias Day = Int

public protocol JWTSignable: Content, JWTPayload {
    func sign(_ app: Application) throws -> String
    func id() -> String
}

protocol JWTAccessToken {
    var refreshTokenID: String { get }
}

protocol JWTRefreshToken {
    var authID: String { get }
    var inactivityEXP: Day { get }
}

protocol JWTAuthToken {
    var clientID: String { get }
    var clientOS: String { get }
}

public final class JWT {
    
    public final class Token {
        public struct V1: Codable {
            let token: String
            let tokenID: String
            public init(_ token: String, _ tokenID: String) {
                self.token = token
                self.tokenID = tokenID
            }
        }
    }
    public final class Tokens {
        public struct V1: Codable {
            let refreshToken: Token.V1
            let accessToken: Token.V1
            
            init(_ refreshToken: Token.V1, _ accessToken: Token.V1) {
                self.refreshToken = refreshToken
                self.accessToken = accessToken
            }
        }
    }
    
    public final class TokenType {
        public enum V1: String, Codable {
            case access = "access"
            case refresh = "refresh"
            case auth = "auth"
        }
    }
    
    public final class TTL {
        public enum V1 {
            static let accessToken = TimeInterval(60 * 1) // 10 min
            static let refreshToken = TimeInterval(60 * 60 * 24 * 30) // 30 day
            static let authToken = TimeInterval(60 * 60 * 24 * 45) // 45 day
        }
    }
    
    public final class ValidationResult {
        public enum V1 <P: JWTSignable> {
            case success(Result)
            case failure
            public struct Result {
                let isVerified: Bool
                let payload: P
            }
        }
    }
    
    public final class AccessToken {
        public struct V1: JWTSignable, JWTAccessToken {
            let userID: String
            let tokenType: TokenType.V1
            let refreshTokenID: String
            
            let iss: IssuerClaim
            let aud: AudienceClaim
            let jti: IDClaim
            let iad: IssuedAtClaim
            let exp: ExpirationClaim
            
            init(
                _ userID: String,
                _ accessTokenID: String,
                _ refreshTokenID: String
            ) {
                let date = Date()
                self.userID = userID
                self.refreshTokenID = refreshTokenID
                self.tokenType = .access
                self.iss = .init(value: "api.vnvce.com")
                self.aud = .init(value: ["vnvce.com"])
                self.jti = .init(value: accessTokenID)
                self.iad = .init(value: date)
                self.exp = .init(value: date.addingTimeInterval(TTL.V1.accessToken))
            }
            
            public func verify(using signer: JWTKit.JWTSigner) throws {
                try self.exp.verifyNotExpired()
            }
            
            public func sign(_ app: Application) throws -> String {
                return try app.jwt.signers.sign(self, kid: .private)
            }
            
            public func id() -> String {
                return self.jti.value
            }
            
            enum CodingKeys: String, CodingKey {
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
    public final class RefreshToken {
        public struct V1: JWTSignable, JWTRefreshToken {
            let userID: String
            let tokenType: TokenType.V1
            let authID: String
            let inactivityEXP: Day
            
            let iss: IssuerClaim
            let aud: AudienceClaim
            let jti: IDClaim
            let iad: IssuedAtClaim
            let exp: ExpirationClaim
            
            init(
                _ userID: String,
                _ refreshTokenID: String,
                _ authID: String
            ) {
                let date = Date()
                self.userID = userID
                self.authID = authID
                self.tokenType = .refresh
                self.inactivityEXP = 7
                self.iss = .init(value: "api.vnvce.com")
                self.aud = .init(value: ["vnvce.com"])
                self.jti = .init(value: refreshTokenID)
                self.iad = .init(value: date)
                self.exp = .init(value: date.addingTimeInterval(TTL.V1.refreshToken))
            }
            
            public func verify(using signer: JWTKit.JWTSigner) throws {
                try self.exp.verifyNotExpired()
            }
            
            public func sign(_ app: Application) throws -> String {
                return try app.jwt.signers.sign(self, kid: .private)
            }
            
            public func id() -> String {
                return self.jti.value
            }
            
            enum CodingKeys: String, CodingKey {
                case userID = "user_id"
                case tokenType = "token_type"
                case authID = "auth_id"
                case inactivityEXP = "inactivity_exp"
                case iss
                case aud
                case jti
                case iad
                case exp
            }
        }
    }
    public final class AuthToken {
        public struct V1: JWTSignable, JWTAuthToken {
            let userID: String
            let clientID: String
            let clientOS: String
            let tokenType: TokenType.V1
            
            let iss: IssuerClaim
            let aud: AudienceClaim
            let jti: IDClaim
            let iad: IssuedAtClaim
            let exp: ExpirationClaim
            
            init(
                _ userID: String,
                _ clientID: String,
                _ clientOS: DeviceOS,
                _ authID: String
            ) {
                let date = Date()
                self.userID = userID
                self.clientID = clientID
                self.clientOS = clientOS.rawValue
                self.tokenType = .auth
                self.iss = .init(value: "api.vnvce.com")
                self.aud = .init(value: ["vnvce.com"])
                self.jti = .init(value: authID)
                self.iad = .init(value: date)
                self.exp = .init(value: date.addingTimeInterval(TTL.V1.authToken))
            }
            
            public func verify(using signer: JWTSigner) throws {
                try self.exp.verifyNotExpired()
            }
            
            public func sign(_ app: Application) throws -> String {
                return try app.jwt.signers.sign(self, kid: .private)
            }
            
            public func id() -> String {
                return self.jti.value
            }
            
            enum CodingKeys: String, CodingKey {
                case userID = "user_id"
                case clientID = "client_id"
                case clientOS = "client_os"
                case tokenType = "token_type"
                case iss
                case aud
                case jti
                case iad
                case exp
            }
            
        }
    }
}
