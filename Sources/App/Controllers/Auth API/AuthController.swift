
import Fluent
import Vapor
import VNVCECore
import JWT
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
        
        
        
        api.post("authorize", use: authorizeHandler)
        api.post("token", use: tokenHandler)
        
        // Refresh: vnvce.com/api/auth/refresh/
        let refresh = api.grouped("refresh")
        /// refresh/ `access-token`
        /// refresh/ `auth-code`
        
        refresh.post("access-token", use: refreshAccessTokenHandler)
        
        api
//            .grouped(TokenJWTAuthenticator2())
//            .grouped(User.guardMiddleware())
            .get("test") { req async throws -> String in
//                let jwt = req.authService.jwt.v1
//                let redis = req.authService.redis.v1
//
//                let codeVerifier = "7lWRWldcct0utEg0JUO-map~yRe4WqpmLhJHKdF4uK8U8Nii0f7303YQQTIglAJHny7pLpQL0.geRihzGQCsiIM2hX1EmZVx7vFypIShx5Zb3B2qB8d3Cy2c_ySmWp1O"
//                let clientID = UUID().uuidString
//
//                let codeChallenge = try await req.authService.code.generateCodeChallenge(fromVerifier: codeVerifier)
//
//                let authCode = try jwt.generateAuthCode("")
                
//                try await redis.addAuthCodeToBucket(userID: "", challenge: codeChallenge, clientID: clientID, authCode.jwtID)
                
//                print(authCode.value)
//                print(clientID)
                
//                let userID = "kerem_cesme"
//                let clientID = UUID().uuidString
//                let sessionID = UUID().uuidString
//
//                let tokens = try jwt.generateTokens(userID)
//                try await redis.addTokensToBucket(tokens: tokens, clientID: clientID)
//                let refreshTokenID = tokens.refreshToken.jwtID
//                try await redis.setLoggedInUserToBucket(userID, refresh: refreshTokenID)
//                try await redis.addSessionToBucket(clientID, userID: userID, refreshTokenID: refreshTokenID)
//                print(tokens.accessToken.value)
                
                return "WORKS"
            }
        
        api
            .get("test-verify") {  req async throws -> String in
                guard let token = req.headers.bearerAuthorization?.token else {
                    print("Missing Header")
                    return "Error"
                }
                
                let key = RedisKey("refresh_tokens:827D62EC-C6C8-47BC-BBA1-ADA2439AAC77")
                
                let ttl = try await req.redis.ttl(key).get().timeAmount?.nanoseconds
                
                print(ttl! / 1_000_000_000)
                
                
                
                return ""
            }
        
        api
            .grouped(TokenAuthMiddleware())
            .get("test-2") { req -> String in
                
                return "HEY"
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
