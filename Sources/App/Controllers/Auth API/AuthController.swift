
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
        
        // Check
        let check = api.grouped("check")
        check.post("phone-number", use: checkPhoneNumberHandler)
        check.post("username", use: checkUsernameHandler)
        
        // Create
        let create = api.grouped("create")
        create.post("reserve-username-and-send-sms-otp", use: reserveUsernameAndSendSMSOTPHandler)
        create.post("account", use: createAccountHandler)
        
        // Login
        let login = api.grouped("login")
        login.post("check-phone-number-and-send-otp", use: checkPhoneNumberAndSendOTPHandler)
        login.post("verify-otp-and-generate-tokens", use: verifyOTPAndLoginHandler)
        
        // Authorization
        let token = api.grouped("token")
        token.post("authorize", use: authorizeHandler)
        token.post("reauthorize", use: reAuthorizeHandler)
        token.post("generate-tokens", use: generateTokensHandler)
        token.post("generate-access-token", use: generateAccessTokenHandler)
        
        api.get("create-user-test") { req async throws -> String in
            let user = User()
            try await user.create(on: req.db)
            let userID = try user.requireID()
            
            return userID.uuidString
        }
        
        api
            .grouped(AuthMiddleware())
//            .grouped(User.guardMiddleware())
            .get("test") { req async throws -> String in
                
                return "WORKS"
            }
        
    }
}
