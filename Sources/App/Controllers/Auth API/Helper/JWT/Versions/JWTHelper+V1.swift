
import Vapor
import JWT
import JWTDecode

typealias TypeV1 = GenerateTokenType.V1

extension JWTHelper.V1 {
    func generateTokens(_ userID: String) throws -> FreshTokens.V1 {
        let refreshToken = try generateToken(userID, type: .refresh)
        let accessToken = try generateToken(userID, type: .access(refreshToken.value))
        
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
    
    func addTokensToBucket(tokens: FreshTokens.V1, clientID: String) async throws {
        let refreshTokenID = tokens.refreshToken.jwtID
        let accessTokenID = tokens.accessToken.jwtID
        try await self.addTokenToBucket(jwtID: refreshTokenID, to: .refreshToken(clientID))
        try await self.addTokenToBucket(jwtID: accessTokenID, to: .accessToken)
    }
    
    func addTokenToBucket(jwtID: String, to bucket: RedisAddBucket.V1) async throws {
        try await self.plugin.addTokenToBucket(jwtID: jwtID, to: bucket)
    }
    
    func getRefreshTokenIdsForUser(_ userID: String) async throws -> Result<RedisUserPayload.V1, RedisError.V1>{
        return try await self.plugin.getRefreshTokensForUser(userID)
    }
    
    func validateToken(decoded: TokenPayload.V1) async throws -> Bool {
        
        let tokenState = try await {
            switch decoded.tokenType {
            case .access:
                let accessTokenState = try await self.plugin.getTokenFromBucket(
                    jwtID: decoded.jti.value,
                    from: .accessToken)
                return accessTokenState
                
            case .refresh:
                let refreshTokenState = try await self.plugin.getTokenFromBucket(
                    jwtID: decoded.jti.value,
                    from: .refreshToken)
                return refreshTokenState
            }
        }()
        
        switch tokenState {
        case let .success(token):
            return token.isActive
        case let .failure(failure):
            print(failure)
            return false
        }
        
    }
    
    func decode(token: String, ignoreExpiry: Bool = false) throws {
        if ignoreExpiry {
            let dic = try JWTDecode.decode(jwt: token).body
            let json = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let jwt = try JSONDecoder().decode(TokenPayload.V1.self, from: json)
            
        } else {
            try self.jwt.verify(token, as: TokenPayload.V1.self)
        }
    }
}

// MARK: Access Token
private extension JWTHelper.V1 {
    private func generateAccessToken(_ userID: String, refreshTokenID: String) throws -> FreshToken.V1 {
        let tokenID = UUID().uuidString
        let expiresIn = JWTTokenTTL.V1.accessToken
        let accessTokenPayload = TokenPayload.V1(
            userID: userID,
            token: .access,
            jwtID: tokenID,
            expiresIn: expiresIn)
        
        let accessToken = try self.jwt.sign(accessTokenPayload, kid: .private)
        return .init(value: accessToken, jwtID: tokenID)
    }
}

// MARK: Refresh Token
private extension JWTHelper.V1 {
    private func generateRefreshToken(_ userID: String) throws -> FreshToken.V1 {
        let tokenID = UUID().uuidString
        let expiresIn = JWTTokenTTL.V1.refreshToken
        let refreshTokenPayload = TokenPayload.V1(
            userID: userID,
            token: .refresh,
            jwtID: tokenID,
            expiresIn: expiresIn)
        
        let refreshToken = try self.jwt.sign(refreshTokenPayload, kid: .private)
        return .init(value: refreshToken, jwtID: tokenID)
    }
}
