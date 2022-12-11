
import Vapor
import JWT
import JWTDecode

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

extension AuthService.JWT.V1 {
    func generateTokens(_ userID: String) throws -> FreshTokens.V1 {
        let refreshToken = try generateToken(userID, type: .refresh)
        let accessToken = try generateToken(userID, type: .access(refreshToken.jwtID))
        
        return .init(refreshToken, accessToken)
    }
    
    func generateToken(_ userID: String, type: TypeV1) throws -> FreshToken.V1 {
        switch type {
        case let .access(refreshTokenID):
            return try generateAccessToken(userID, refreshTokenID: refreshTokenID)
        case .refresh:
            return try generateRefreshToken(userID)
        }
    }
    
    func generateAuthCode() throws -> FreshToken.V1 {
        let tokenID = UUID().uuidString
        let authCodePayload = AuthCodePayload.V1(jwtID: tokenID)
        let authCodeToken = try self.app.jwt.signers.sign(authCodePayload, kid: .private)
        return .init(value: authCodeToken, jwtID: tokenID)
    }
    
    func verify(_ token: String) async throws {
        do {
            let payload = try self.app.jwt.signers.verify(token, as: TokenPayload.V1.self)
            switch payload.tokenType {
            case .access: try await verifyAccessToken(payload) // Access Token
            case .refresh: break // Refresh Token
            }
        } catch {
            // Token Not verified
        }
    }
    
    func verifyAccessToken(_ payload: TokenPayload.V1) async throws {
        guard let refreshTokenID = payload.refreshTokenID else {
            print("The Access Token's JWT Payload must have the Refresh Token's ID.")
            return
        }
        let redis = self.app.authService.redis.v1
        let accessTokenID = payload.jti.value
        
        let accessTokenResult = try await redis.getTokenFromBucket(jwtID: accessTokenID, from: .accessToken)
        let refreshTokenResult = try await redis.getTokenFromBucket(jwtID: refreshTokenID, from: .refreshToken)
        let userResult = try await redis.getRefreshTokensForUser(payload.userID)
        
        switch accessTokenResult {
        case .notFound:
            /// Access Token is not found in Redis.
            return
        case let .success(accessToken):
            if !accessToken.isActive {
                /// Detected authorization attempt with
                /// a revoked Access Token.
                return
            }
            switch refreshTokenResult {
            case .notFound:
                /// Access Token was revoked because Refresh Token
                /// is not found in Redis.
                try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
                return
            case let .success(refreshToken):
                if !refreshToken.isActive {
                    /// Access Token was revoked because the Refresh Token
                    /// `isActive` key is marked `false` in Redis.
                    try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
                    return
                }
                switch userResult {
                case .notFound:
                    /// Refresh Token and Access Token was revoked because
                    /// the user not found in Redis.
                    try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
//                    try await redis.revokeTokenFromBucket(refreshTokenID, payload: refreshToken, from: .refreshToken)
                    return
                case let .success(user):
                    if !user.refreshTokens.contains(refreshTokenID) {
                        /// The Refresh Token was revoked because it
                        /// could not be found among the user's tokens.
                        try await redis.revokeTokenFromBucket(accessTokenID, payload: accessToken, from: .accessToken)
//                        try await redis.revokeTokenFromBucket(refreshTokenID, payload: refreshToken, from: .refreshToken)
                        return
                    }
                    
                    print("AUTHENTICATED")
                    return
                }
                
            }
            
        }
        
        switch userResult {
        case .notFound:
            print("User not found on Redis")
        case let .success(user):
            print(refreshTokenID)
            guard user.refreshTokens.contains(refreshTokenID) else {
                print("Refresh Token does not exist in the user's Refresh Tokens.")
                return
            }
            switch accessTokenResult {
            case .notFound:
                print("Access Token not found on Redis")
            case let .success(payload):
                guard payload.isActive else {
                    print("Access Token isActive value is marked false")
                    return
                }
                switch refreshTokenResult {
                case .notFound:
                    print("Refresh Token not found on Redis")
                case let .success(payload):
                    guard payload.clientID != nil else {
                        print("Refresh Token must have clientID in Redis model.")
                        return
                    }
                    guard payload.isActive else {
                        print("Refresh Token isActive value is marked false")
                        return
                    }
                    print("AUTHENTICATED")
                }
            }
        }
        
    }
    
    func verifyOLD(_ jwt: String) async throws {
        let redis = self.app.authService.redis.v1
        if let payload = try? self.app.jwt.signers.verify(jwt, as: TokenPayload.V1.self) {
            // Step 1 - Verified
            let jwtID = payload.jti.value
            let result = try await redis.getTokenFromBucket(jwtID: jwtID, from: .accessToken)
            
            switch result {
            case let .success(tokenPayload):
                if tokenPayload.isActive {
                    print("Verified")
                } else {
                    // Token isActive marked false
                    print("Unauthenticate 2")
                }
                return
            case .notFound:
                // Token has not found in redis db
                print("Unauthenticate 1")
            }
        } else {
            // Token has expire
            do {
                print("burada")
                let payload = try decode(jwt)
                // Not verified
                // Try validate refresh token
                if let refreshTokenID = payload.refreshTokenID, payload.tokenType == .access {
                    // This is a access token
                    
                    
                } else {
                    // This is a refresh token
                    
                }
                
                
            } catch {
                print("Not decodable JWT")
            }
            
        }
    }
    
    func decode(_ jwt: String) throws -> TokenPayload.V1 {
        let dictionary = try JWTDecode.decode(jwt: jwt).body
        let json = try JSONSerialization.data(withJSONObject: dictionary)
        
        return try decoder.decode(TokenPayload.V1.self, from: json)
    }
}

// MARK: Access Token
private extension AuthService.JWT.V1 {
    private func generateAccessToken(_ userID: String, refreshTokenID: String) throws -> FreshToken.V1 {
        let tokenID = UUID().uuidString
        let expiresIn = JWTTokenTTL.V1.accessToken
        let accessTokenPayload = TokenPayload.V1(
            userID: userID,
            token: .access,
            refreshTokenID: refreshTokenID,
            jwtID: tokenID,
            expiresIn: expiresIn)
        
        let accessToken = try self.app.jwt.signers.sign(accessTokenPayload, kid: .private)
        return .init(value: accessToken, jwtID: tokenID)
    }
}

// MARK: Refresh Token
private extension AuthService.JWT.V1 {
    private func generateRefreshToken(_ userID: String) throws -> FreshToken.V1 {
        let tokenID = UUID().uuidString
        let expiresIn = JWTTokenTTL.V1.refreshToken
        let refreshTokenPayload = TokenPayload.V1(
            userID: userID,
            token: .refresh,
            jwtID: tokenID,
            expiresIn: expiresIn)
        
        let refreshToken = try self.app.jwt.signers.sign(refreshTokenPayload, kid: .private)
        
        return .init(value: refreshToken, jwtID: tokenID)
    }
}
