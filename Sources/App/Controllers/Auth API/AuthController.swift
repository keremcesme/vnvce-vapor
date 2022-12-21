
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
        
        let check = api.grouped("check")
        check.post("phone-number", use: checkPhoneNumberHandler)
        check.post("username", use: checkUsernameHandler)
        
        api.post("reserve-username-and-send-sms-otp", use: reserveUsernameAndSendSMSOTPHandler)
        
        api.post("create-account", use: createAccountHandler)
        
        api.get("create-user-test") { req async throws -> String in
            let user = User()
            try await user.create(on: req.db)
            let userID = try user.requireID()
            
            return userID.uuidString
        }
        
        api.post("authorize", use: authorizeHandler)
        api.post("reauthorize", use: reAuthorizeHandler)
        
        let pkce = api.grouped("pkce")
        
        pkce.post("generate-tokens", use: generateTokensHandler)
        
        let refreshToken = api.grouped("refresh-token")
        refreshToken.post("generate-access-token", use: generateAccessTokenHandler)
        
        api.post("send-sms") { req async throws -> SMSOTPModel.V1 in
            return try await sendSMSOTPV1(phoneNumber: "+905533352131", clientID: "as", clientOS: .ios, req)
        }
        
        api
            .grouped(AuthMiddleware())
//            .grouped(User.guardMiddleware())
            .get("test") { req async throws -> String in
                
                return "WORKS"
            }
        
    }
}
