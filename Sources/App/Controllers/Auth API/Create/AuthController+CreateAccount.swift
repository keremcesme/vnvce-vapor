
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
        
        let p = try req.content.decode(CreateAccountPayload.V1.self)
        
        let otpService = req.authService.otp.v1
        let usernameService = req.authService.reservedUsername.v1
        let jwtService = req.authService.jwt.v1
        let redisService = req.authService.redis.v1
        
        let phoneNumber = String(p.phoneNumber.countryCode) + String(p.phoneNumber.nationalNumber)
        
        try await usernameService.verifyUsername(p.username, on: req)
        
        try await otpService.verifyOTP(phoneNumber: phoneNumber, code: p.code, on: req)
        
        guard let countryID = try await Country.query(on: req.db)
            .filter(\.$iso == p.phoneNumber.country)
            .filter(\.$phonecode == p.phoneNumber.countryCode)
            .first()?.requireID()
        else {
            throw Abort(.badRequest, reason: "Missing country.")
        }
        
        let userID: String = try await req.db.transaction {
            let user = User()
            try await user.create(on: $0)
            let userID = try user.requireID()
            try await user.$username.create(.init(username: p.username, user: userID), on: $0)
            try await user.$phoneNumber.create(.init(phoneNumber: "+\(phoneNumber)", userID: userID, countryID: countryID ), on: $0)
            try await user.$dateOfBirth.create(.init(userID: userID, day: p.dateOfBirth.day, month: p.dateOfBirth.month, year: p.dateOfBirth.year), on: $0)
            try await user.$membership.create(.init(userID: userID), on: $0)
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
