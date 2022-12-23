
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func createAccountHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await createAccountV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func createAccountV1(_ req: Request) async throws -> CreateAccountResponse.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let p = try req.query.decode(CreateAccountParams.V1.self)
        
        let otpService = req.authService.otp.v1
        let usernameService = req.authService.reservedUsername.v1
        let jwtService = req.authService.jwt.v1
        let redisService = req.authService.redis.v1
        
        try await usernameService.verifyUsername(p.username, on: req)
        try await otpService.verifyOTP(phoneNumber: p.phoneNumber, code: p.code, on: req)
        
        let userID: String = try await req.db.transaction {
            let user = User()
            try await user.create(on: $0)
            let userID = try user.requireID()
            try await user.$username.create(.init(username: p.username, user: userID), on: $0)
//            try await user.$phoneNumber.create(.init(phoneNumber: p.phoneNumber, userID: userID, countryID: ), on: $0)
            return userID.uuidString
        }
        
        let authToken = try jwtService.generateAuthToken(userID, clientID, clientOS)
        let authID = authToken.tokenID
        
        await redisService.addAuth(authID: authID, challenge: p.codeChallenge)
        
        if let session = try await Session.query(on: req.db)
            .filter(\.$clientID == clientID)
            .filter(\.$clientOS == clientOS)
            .field(\.$authID)
            .first() {
            await redisService.deleteAuthWithRefreshTokens(session.authID)
            try await session.delete(force: true, on: req.db)
        }
        
        return .init(userID, authToken.token, authToken.tokenID)
    }
}

extension CreateAccountResponse.V1: Content {}
