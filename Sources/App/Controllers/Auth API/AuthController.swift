
import Fluent
import Vapor
import VNVCECore
import Redis

// MARK: AuthController - AUTH API
// Here are all the routes for authorization.

public struct AuthController: RouteCollection {
    private let endpoint = Endpoint.shared.routes.auth
    
//    private let v1 = V1.shared
    
    // MARK: Auth: vnvce.com/api/auth/
    public func boot(routes: RoutesBuilder) throws {
        let versionMiddleware = VersionMiddleware()
        let api = routes.grouped("auth").grouped(versionMiddleware)
        
        // Create: vnvce.com/api/auth/check/
        let check = api.grouped("check")
        check.post("phone-number", use: checkPhoneNumberHandler)
        check.post("username", use: checkUsernameHandler)
        
        api.post("reserve-username-and-send-sms-otp", use: reserveUsernameAndSendSMSOTPHandler)
        
        api.post("create-account", use: createAccountHandler)
        
        func generateTokens(_ req: Request) async throws {
            let helper = TokenJWTHelper.shared
            let date = Date()
            
            let userID = UUID().uuidString
            
            
            let tokens = try helper.generateTokens(userID: userID, req)
            
            let refreshTokenKey = RedisKey("refresh_tokens:\(tokens.refreshToken.jwtID)")
            let accessTokenKey = RedisKey("access_tokens:\(tokens.accessToken.jwtID)")
            let userKey = RedisKey("users:\(userID)")
            
            let refreshTokenPayload = RedisTokenPayloadOLD(
                isActive: true,
                stored: date.timeIntervalSince1970,
                ttl: 2_419_000)
            
            let accessTokenPayload = RedisTokenPayloadOLD(
                isActive: true,
                stored: date.timeIntervalSince1970,
                ttl: 1800)
            
            let userPayload: Codable = [
                "tokens": [tokens.refreshToken.jwtID]
            ]
            
            try await req.redis.setex(refreshTokenKey, toJSON: refreshTokenPayload, expirationInSeconds: 2_419_000)
            
            try await req.redis.setex(accessTokenKey, toJSON: accessTokenPayload, expirationInSeconds: 1800)
            
            try await req.redis.setex(userKey, toJSON: userPayload, expirationInSeconds: 2_419_000)
            
            
            
        }
        
        api
//            .grouped(TokenJWTAuthenticator2())
//            .grouped(User.guardMiddleware())
            .get("test") { req async throws -> String in
                let helper = JWTHelper.V1(req)
                let plugin = JWTPlugin.V1(req.redis)
                
                let tokens = try helper.generateTokens("kerem_cesme")
                
                let refreshToken = tokens.refreshToken
                let accessToken = tokens.accessToken
                
                try await plugin.addTokenToBucket(jwtID: refreshToken.jwtID, to: .refreshToken)
                try await plugin.addTokenToBucket(jwtID: accessToken.jwtID, to: .accessToken)
                try await plugin.setLoggedInUserToBucket("kerem_cesme", refresh: refreshToken.jwtID)
                
                
                return "WORKS"
            }
        
        api.get("login") { req async throws -> String in
            let helper = JWTHelper.V1(req)
            let plugin = JWTPlugin.V1(req.redis)
            
            let userID = "kerem_cesme"
            
            let tokens = try helper.generateTokens(userID)
            
            let refreshToken = tokens.refreshToken
            let accessToken = tokens.accessToken
            
            try await plugin.addTokenToBucket(jwtID: refreshToken.jwtID, to: .refreshToken)
            try await plugin.addTokenToBucket(jwtID: accessToken.jwtID, to: .accessToken)
            
            let result = try await plugin.getRefreshTokensForUser(userID)
            
            switch result {
            case let .success(result):
                let tokenIDs = result.tokens
                try await plugin.setLoggedInUserToBucket(userID, refresh: refreshToken.jwtID, currentTokens: tokenIDs)
            case let .failure(failure):
                print(failure)
            }
            
            
            return "WORKS"
        }
        
        
        
        // Create: vnvce.com/api/auth/create/
        try api.grouped("create").register(collection: CreateAccountController())
        
        // Login: vnvce.com/api/auth/login/
        try api.grouped("login").register(collection: LoginAccountController())
        
        // Token: vnvce.com/api/auth/token/
        
        
        // MARK: OLD Codes
        
//        try routes
//            .grouped(Endpoint.Auth.Login.root.toPathComponents)
//            .register(collection: loginController)
        
//        let auth = routes.grouped("auth")
//
//
//        let create = auth.grouped("create")
//        try create.register(collection: createController)
//
//        let loginController = LoginAccountController()
//        let login = auth.grouped("login")
//        try login.register(collection: loginController)
        
        
//        v1.routes(routes)
        
    }
}
