
import Vapor
import JWT
import VNVCECore

extension AuthController {
    public func reserveUsernameAndSendSMSOTPHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await reserveUsernameAndSendSMSOTPV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func reserveUsernameAndSendSMSOTPV1(_ req: Request) async throws -> OTPResponse.V1 {
        let p = try req.query.decode(ReserveUsernameAndSendOTPParams.V1.self)
        let otpService = req.authService.otp.v1
        let usernameService = req.authService.reservedUsername.v1
        
        let usernameAvailability = try await usernameService.checkUsername(p.username, on: req)
        
        guard usernameAvailability == .notUsed || usernameAvailability == .reservedBySameUser else {
            throw Abort(.notFound)
        }
        
        let phoneAvailability = try await otpService.checkPhoneNumber(phoneNumber: p.phoneNumber, on: req)
        
        guard phoneAvailability == .notUsed || phoneAvailability == .otpExpectedBySameUser else {
            throw Abort(.notFound)
        }
        
        try await usernameService.reserveUsername(p.username, on: req)
        
        if phoneAvailability == .otpExpectedBySameUser {
            var phone: String {
                let plus = "+"
                if p.phoneNumber[0] == plus {
                    return p.phoneNumber
                } else {
                    return plus + p.phoneNumber
                }
            }
            guard let otp = await req.authService.redis.v1.getOTPWithTTL(phone),
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
            let otp = try await otpService.sendOTP(p.phoneNumber, reason: .create, on: req)
            
            return otp
        }
        
        
    }
    
}
