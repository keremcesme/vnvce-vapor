
import Vapor
import Fluent
import VNVCECore

extension AuthController {
    public func checkPhoneNumberAndSendOTPHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await checkPhoneNumberAndSendOTPV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func checkPhoneNumberAndSendOTPV1(_ req: Request) async throws -> AuthorizeAndOTPResponse.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS?.convertClientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let p = try req.query.decode(CheckPhoneNumberAndSendOTPParams.V1.self)
        
        let jwtService = req.authService.jwt.v1
        let redisService = req.authService.redis.v1
        let otpService = req.authService.otp.v1
        
        let phoneAvailability = try await otpService.checkPhoneNumber(phoneNumber: p.phoneNumber, on: req)
        
        guard phoneAvailability == .exist || phoneAvailability == .otpExpectedBySameUser else {
            throw Abort(.notFound)
        }
        
        guard let userID = try await User.query(on: req.db)
            .join(child: \.$phoneNumber)
            .filter(PhoneNumber.self, \PhoneNumber.$phoneNumber == p.phoneNumber)
            .field(\.$id)
            .first()?
            .requireID()
            .uuidString
        else {
            throw Abort(.notFound)
        }
        
        let authToken = try jwtService.generateAuthToken(userID, clientID, clientOS)
        let authID = authToken.tokenID
        
        await redisService.addAuth(authID: authID, challenge: p.codeChallenge)
        
        let otp = try await otpService.sendOTP(p.phoneNumber, reason: .login, on: req)
        let authorize = AuthorizeResponse.V1(authToken.token, authToken.tokenID)
        
        return .init(otp, authorize)
    }
    
}

extension AuthorizeAndOTPResponse.V1: Content {}
