
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthService.OTP {
    public struct V1 {
        public let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

public extension AuthService.OTP.V1 {
    typealias Availability = PhoneNumberAvailability.V1
    
    ///
    /// Headers:
    ///  1 - X-Client-ID
    ///  2 - X-Client-OS
    ///  3 - X-OTP-ID (Optional)
    ///
    /// Params:
    ///  1 - Phone Number
    func checkPhoneNumber(phoneNumber: String, on req: Request) async throws -> Availability {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        
        var phone: String {
            let plus = "+"
            if phoneNumber[0] == plus {
                return phoneNumber
            } else {
                return plus + phoneNumber
            }
        }
        
        let redis = req.authService.redis.v1
        
        if try await phoneNumberQuery(phone, on: req.db) != nil {
            return .exist
        }
        
        guard let otp = await redis.getOTPWithTTL(phone) else {
            return .notUsed
        }
        
        let otpID = req.headers.otpID
        guard let otpID, otpID == otp.payload.otpID,
                  otp.payload.clientID == clientID,
                  otp.payload.clientOS == clientOS
        else {
            return .otpExpected
        }
        
        return .otpExpectedBySameUser
    }
    
    ///
    /// Headers:
    ///  1 - X-Client-ID
    ///  2 - X-Client-OS
    ///  3 - X-User-ID (Optional)
    ///
    /// Params:
    ///  1 - Phone Number
    ///
    func sendOTP(_ phoneNumber: String, reason: CheckPhoneNumberParams.V1.Reason, on req: Request) async throws -> OTPResponse.V1 {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS?.convertClientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        
        var phone: String {
            let plus = "+"
            if phoneNumber[0] == plus {
                return phoneNumber
            } else {
                return plus + phoneNumber
            }
        }
        
        let userID = req.headers.userID
        
        let jwt = req.authService.jwt.v1
        let redis = req.authService.redis.v1
        let sms = req.application.aws.sms
        
        let currentDate = Date()
        
        let duration = 60
        
        let symmetricKey = SymmetricKey(size: .bits128)
        let totp = TOTP(key: symmetricKey, digest: .sha256, digits: .six, interval: duration)
        let code = totp.generate(time: currentDate)
        
        let encryptedCode = try Bcrypt.hash(code)
        
        let otpToken = try jwt.generateOTPToken(userID, clientID, clientOS)
        
        await redis.addOTP(
            phoneNumber: phone,
            encryptedCode: encryptedCode,
            otpID: otpToken.tokenID,
            clientID: clientID,
            clientOS: clientOS.rawValue)
        
        var reasonMessage: String {
            switch reason {
            case .create:
                return "creating a"
            case .login:
                return "login"
            }
        }
        
        let message = """
Verification code for \(reasonMessage) vnvce account: \(code).
If you did not request this, disregard this message.
"""
        
        try await sms.send(to: phone, message: message)
        
        let createdAt = currentDate.timeIntervalSince1970
        let expireAt = currentDate.addingTimeInterval(TimeInterval(duration)).timeIntervalSince1970
        
        return .init(otp: .init(id: otpToken.tokenID, token: otpToken.token), createdAt: createdAt, expireAt: expireAt)
    }
    
    ///
    /// Headers:
    ///  1 - X-Client-ID
    ///  2 - X-Client-OS
    ///  3 - X-User-ID (Optional)
    ///
    /// Authorization (Bearer):
    ///     OTP Token
    ///
    /// Params:
    ///  1 - Phone Number
    ///  2 - OTP Code
    ///
    func verifyOTP(phoneNumber: String, code: String, on req: Request) async throws {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS?.convertClientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        
        guard let otpToken = req.headers.bearerAuthorization?.token else {
            throw Abort(.badRequest, reason: "The `OTP Token` header is missing.")
        }
        
        let userID = req.headers.userID
        
        var phone: String {
            let plus = "+"
            if phoneNumber[0] == plus {
                return phoneNumber
            } else {
                return plus + phoneNumber
            }
        }
        
        let redis = req.authService.redis.v1
        
        guard let otpJWT = try? req.jwt.verify(otpToken, as: JWT.OTP.V1.self),
                  otpJWT.userID == userID,
                  otpJWT.clientID == clientID,
                  otpJWT.clientOS == clientOS.rawValue,
              let otp = await redis.getOTP(phone),
                  otp.userID == userID,
                  otp.clientID == clientID,
                  otp.clientOS == clientOS.rawValue,
                  otp.otpID == otpJWT.id(),
              try Bcrypt.verify(code, created: otp.encryptedCode)
        else {
            throw Abort(.forbidden)
        }
        await redis.deleteOTP(phone)
    }
    
    private func phoneNumberQuery(_ phoneNumber: String, on db: Database) async throws -> PhoneNumber? {
        return try await PhoneNumber
            .query(on: db)
            .filter(\.$phoneNumber == phoneNumber)
            .first()
    }
}

extension PhoneNumberAvailability.V1: Content {}
extension OTPResponse.V1: Content {}
