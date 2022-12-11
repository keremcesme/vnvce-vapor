
import Vapor
import Fluent
import RediStack
import Redis
import VNVCECore

extension AuthController {
    public func createAccountHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            return try await createAccountV1(req)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func createAccountV1(_ req: Request) async throws -> AnyAsyncResponse {
        let p = try req.content.decode(VNVCECore.CreateAccountPayload.V1.self)

        let phoneNumberKey = RedisKey("phone_number:\(p.phoneNumber)")
        let usernameKey = RedisKey("reserved:\(p.username)")
        
        guard let otp = try await req.redis.get(phoneNumberKey, asJSON: RedisOTPModel.V1.self) else {
            return .init(ResultResponse.V1(error: true, description: "OTP is expired."))
        }
        
        guard
            try Bcrypt.verify(p.code, created: otp.encryptedCode),
            try Bcrypt.verify(p.clientID, created: otp.encryptedClientID)
        else {
            return .init(ResultResponse.V1(error: true, description: "Invalid code."))
        }
        
        _ = try await req.redis.delete(phoneNumberKey).get()
        _ = try await req.redis.delete(usernameKey).get()
        
        let user = User()
        try await user.create(on: req.db)
        let userID = try user.requireID()
        try await user.$username.create(.init(username: p.username, user: userID), on: req.db)
        try await user.$phoneNumber.create(.init(phoneNumber: p.phoneNumber, user: userID), on: req.db)
        
        // generate auth code and sign with JWT
//        let authCode = try req.authService.jwt.v1.generateAuthCode()
//        // add redis
//        try await req.authService.redis.v1.addAuthCodeToBucket(challenge: "", clientID: "", authCode.jwtID)
        
        return .init("Account Is Created")
    }
}

extension VNVCECore.CreateAccountPayload.V1: Content { }
