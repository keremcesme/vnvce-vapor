
import Vapor
import JWT
import JWTDecode
import VNVCECore

extension AuthService.JWT {
    public struct V1 {
        public let app: Application
        
        private let decoder = JSONDecoder()
        
        init(_ app: Application) {
            self.app = app
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
    }
}

public extension AuthService.JWT.V1 {
    typealias AccessToken = JWT.AccessToken.V1
    typealias RefreshToken = JWT.RefreshToken.V1
    typealias AuthToken = JWT.AuthToken.V1
    /// This method generates a `Refresh Token` and an `Access Token`.
    /// This method is only used for `login`, `sign up` operations.
    /// As an exception, it can be used after the RT has expired
    /// and the `PKCE Flow` has been successfully completed.
    func generateTokens(_ userID: String, _ authID: String) throws -> JWT.Tokens.V1 {
        let refreshToken = try generateRefreshToken(userID, authID)
        let accessToken = try generateAccessToken(userID, refreshToken.tokenID)
        return .init(refreshToken, accessToken)
    }
    
    /// An `Access Token` will be generated.
    func generateAccessToken(_ userID: String, _ refreshTokenID: String ) throws -> JWT.Token.V1 {
        let accessTokenID = UUID().uuidString
        let payload = AccessToken(userID, accessTokenID, refreshTokenID)
        let accessToken = try payload.sign(self.app)
        return .init(accessToken, accessTokenID)
    }
    
    /// An `Refresh Token` will be generated.
    func generateRefreshToken(_ userID: String, _ authID: String) throws -> JWT.Token.V1 {
        let refreshTokenID = UUID().uuidString
        let payload = RefreshToken(userID, refreshTokenID, authID)
        let refreshToken = try payload.sign(self.app)
        return .init(refreshToken, refreshTokenID)
    }
    
    /// An `Auth Token` will be generated.
    func generateAuthToken(_ userID: String, _ clientID: String, _ clientOS: ClientOS) throws -> JWT.Token.V1 {
        let authID = UUID().uuidString
        let payload = AuthToken(userID, clientID, clientOS, authID)
        let authToken = try payload.sign(self.app)
        return .init(authToken, authID)
    }
    
    typealias ValidationResult<P: JWTSignable> = JWT.ValidationResult.V1<P>
    func validate<P: JWTSignable>(_ token: String, as payload: P.Type) -> ValidationResult<P> {
        do {
            let verifiedPayload = try self.app.jwt.signers.verify(token, as: payload)
            return .success(.init(isVerified: true, payload: verifiedPayload))
        } catch {
            do {
                let unverifiedPayload = try self.app.jwt.decode(token, as: payload)
                return .success(.init(isVerified: false, payload: unverifiedPayload))
            } catch {
                return .failure
            }
        }
    }
}

extension AuthService.JWT.V1 {
//    func generateTokens(_ userID: String) throws -> FreshTokens.V1 {
//        let refreshToken = try generateToken(userID, type: .refresh)
//        let accessToken = try generateToken(userID, type: .access)
//
//        return .init(refreshToken, accessToken)
//    }
    
//    func generateToken(_ userID: String, type: TokenType.V1) throws -> FreshToken.V1 {
//        switch type {
//        case .access:
//            return try generateAccessToken(userID)
//        case .refresh:
//            return try generateRefreshToken(userID)
//        }
//    }
//
//    func generateAuthCode(_ userID: String) throws -> FreshToken.V1 {
//        let tokenID = UUID().uuidString
//        let authCodePayload = AuthCodePayload.V1(userID: userID, jwtID: tokenID)
//        let authCodeToken = try self.app.jwt.signers.sign(authCodePayload, kid: .private)
//        return .init(value: authCodeToken, jwtID: tokenID)
//    }
//
//    func verify(_ token: String) async throws {
//        do {
//            let payload = try self.app.jwt.signers.verify(token, as: TokenPayload.V1.self)
//            switch payload.tokenType {
//            case .access: break // Access Token
//            case .refresh: break // Refresh Token
//            }
//        } catch {
//            // Token Not verified
//        }
//    }
    
//    func verifyAccessToken(_ payload: TokenPayload.V1) async throws {
//        guard let refreshTokenID = payload.refreshTokenID else {
//            print("The Access Token's JWT Payload must have the Refresh Token's ID.")
//            return
//        }
//        let redis = self.app.authService.redis.v1
//        let accessTokenID = payload.jti.value
//
//        let accessTokenResult = try await redis.getTokenFromBucket(jwtID: accessTokenID, from: .accessToken)
//        let refreshTokenResult = try await redis.getTokenFromBucket(jwtID: refreshTokenID, from: .refreshToken)
//        let userResult = try await redis.getRefreshTokensForUser(payload.userID)
//
//        switch accessTokenResult {
//        case .notFound:
//            /// Access Token is not found in Redis.
//            return
//        case let .success(accessToken):
//            if !accessToken.isActive {
//                /// Detected authorization attempt with
//                /// a revoked Access Token.
//                return
//            }
//            switch refreshTokenResult {
//            case .notFound:
//                /// Access Token was revoked because Refresh Token
//                /// is not found in Redis.
//                try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
//                return
//            case let .success(refreshToken):
//                if !refreshToken.isActive {
//                    /// Access Token was revoked because the Refresh Token
//                    /// `isActive` key is marked `false` in Redis.
//                    try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
//                    return
//                }
//                switch userResult {
//                case .notFound:
//                    /// Refresh Token and Access Token was revoked because
//                    /// the user not found in Redis.
//                    try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
////                    try await redis.revokeTokenFromBucket(refreshTokenID, payload: refreshToken, from: .refreshToken)
//                    return
//                case let .success(user):
//                    if !user.refreshTokens.contains(refreshTokenID) {
//                        /// The Refresh Token was revoked because it
//                        /// could not be found among the user's tokens.
//                        try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
////                        try await redis.revokeTokenFromBucket(refreshTokenID, payload: refreshToken, from: .refreshToken)
//                        return
//                    }
//
//                    print("AUTHENTICATED")
//                    return
//                }
//
//            }
//
//        }
//
//        switch userResult {
//        case .notFound:
//            print("User not found on Redis")
//        case let .success(user):
//            print(refreshTokenID)
//            guard user.refreshTokens.contains(refreshTokenID) else {
//                print("Refresh Token does not exist in the user's Refresh Tokens.")
//                return
//            }
//            switch accessTokenResult {
//            case .notFound:
//                print("Access Token not found on Redis")
//            case let .success(payload):
//                guard payload.isActive else {
//                    print("Access Token isActive value is marked false")
//                    return
//                }
//                switch refreshTokenResult {
//                case .notFound:
//                    print("Refresh Token not found on Redis")
//                case let .success(payload):
//                    guard payload.clientID != nil else {
//                        print("Refresh Token must have clientID in Redis model.")
//                        return
//                    }
//                    guard payload.isActive else {
//                        print("Refresh Token isActive value is marked false")
//                        return
//                    }
//                    print("AUTHENTICATED")
//                }
//            }
//        }
//
//    }
    
//    func decode(_ jwt: String) throws -> TokenPayload.V1 {
//        let dictionary = try JWTDecode.decode(jwt: jwt).body
//        let json = try JSONSerialization.data(withJSONObject: dictionary)
//
//        return try decoder.decode(TokenPayload.V1.self, from: json)
//    }
}

// MARK: Access Token
//private extension AuthService.JWT.V1 {
//    private func generateAccessToken(_ userID: String) throws -> FreshToken.V1 {
//        let tokenID = UUID().uuidString
//        let expiresIn = JWTTokenTTL.V1.accessToken
//        let accessTokenPayload = TokenPayload.V1(
//            userID: userID,
//            token: .access,
//            jwtID: tokenID,
//            expiresIn: expiresIn)
//
//        let accessToken = try self.app.jwt.signers.sign(accessTokenPayload, kid: .private)
//        return .init(value: accessToken, jwtID: tokenID)
//    }
//}

// MARK: Refresh Token
//private extension AuthService.JWT.V1 {
//    private func generateRefreshToken(_ userID: String) throws -> FreshToken.V1 {
//        let tokenID = UUID().uuidString
//        let expiresIn = JWTTokenTTL.V1.refreshToken
//        let refreshTokenPayload = TokenPayload.V1(
//            userID: userID,
//            token: .refresh,
//            jwtID: tokenID,
//            expiresIn: expiresIn)
//
//        let refreshToken = try self.app.jwt.signers.sign(refreshTokenPayload, kid: .private)
//
//        return .init(value: refreshToken, jwtID: tokenID)
//    }
//}
