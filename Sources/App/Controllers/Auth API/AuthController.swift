
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
            .grouped(AuthMiddleware())
//            .grouped(User.guardMiddleware())
            .get("test") { req async throws -> String in
                
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
