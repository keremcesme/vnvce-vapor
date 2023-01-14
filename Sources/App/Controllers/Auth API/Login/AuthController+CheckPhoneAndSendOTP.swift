
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
        
        let phoneAvailability = try await otpService.checkPhoneNumber(phoneNumber: p.phoneNumber, reason: .login, on: req)
        
        guard phoneAvailability == .exist || phoneAvailability == .otpExpectedBySameUser else {
            throw Abort(.notFound)
        }
        
        var phone: String {
            let plus = "+"
            if p.phoneNumber[0] == plus {
                return p.phoneNumber
            } else {
                return plus + p.phoneNumber
            }
        }
        
        guard let userID = try await User.query(on: req.db)
            .join(child: \.$phoneNumber)
            .filter(PhoneNumber.self, \PhoneNumber.$phoneNumber == phone)
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
        
        let otp: OTPResponse.V1 = try await {
            if phoneAvailability == .otpExpectedBySameUser {
                guard let otp = await redisService.getOTPWithTTL(phone),
                      let otpToken = req.headers.otpToken,
                      let otpID = req.headers.otpID,
                      let otpJWT = try? req.jwt.verify(otpToken, as: JWT.OTP.V1.self),
                      otpJWT.id() == otpID
                else {
                    throw Abort(.notFound)
                }
                
                let currentDate = Date().timeIntervalSince1970
                let secAgo = 60 - otp.ttl
                let createdAt = currentDate - TimeInterval(secAgo)
                let expiredAt = currentDate + 60 - TimeInterval(secAgo)
                
                return .init(otp: .init(id: otpID, token: otpToken), createdAt: createdAt, expireAt: expiredAt)
            } else {
                let otp = try await otpService.sendOTP(phone, reason: .login, on: req)
                return otp
            }
        }()
        
        let authorize = AuthorizeResponse.V1(authToken.token, authToken.tokenID)
        
        return .init(otp, authorize)
    }
}
