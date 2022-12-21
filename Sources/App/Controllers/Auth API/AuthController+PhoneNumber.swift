
import Vapor
import Fluent
import RediStack
import Redis
import VNVCECore

extension AuthController {
    public func checkPhoneNumberHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let p = try req.query.decode(CheckPhoneNumberParams.V1.self)
            let result = try await checkPhoneNumberV1(phoneNumber: p.phoneNumber, req)
            let availability = result.availability
            let description = availability.description
            
            switch p.reason {
            case .create:
                if availability == .notUsed || availability == .otpExpectedBySameUser {
                    return .init(ResultResponse.V1(error: false, description: description))
                } else {
                    return .init(ResultResponse.V1(error: true, description: description))
                }
            case .login:
                if availability == .exist || availability == .otpExpectedBySameUser {
                    return .init(ResultResponse.V1(error: false, description: description))
                } else {
                    return .init(ResultResponse.V1(error: true, description: description))
                }
            }
        default:
            throw Abort(.notFound)
        }
    }
    
    public func checkPhoneNumberV1(phoneNumber: String, _ req: Request) async throws -> PhoneNumberAvailability.V1 {
        guard let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let phoneNumber = "+" + phoneNumber
        
        let phoneQuery = try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == phoneNumber)
            .first()
        
        guard phoneQuery == nil else {
            return .init(availability: .exist)
        }
        
        let redis = req.authService.redis.v1
        
        guard let otp = await redis.getOTPWithTTL(phoneNumber) else {
            return .init(availability: .notUsed)
        }
        
        let otpID = req.headers.otpID
        guard let otpID, otpID == otp.payload.otpID,
                  otp.payload.clientID == clientID,
                  otp.payload.clientOS == clientOS
        else {
            return .init(availability: .otpExpected)
        }
        
        let date = Date().timeIntervalSince1970
        let createdAt = date - TimeInterval(Redis.TTL.V1.otp - otp.ttl)
        let expireAt = date + TimeInterval(otp.ttl)
        
        let otpModel = SMSOTPModel.V1(otpID: otpID, createdAt: createdAt, expireAt: expireAt)
        
        return .init(otp: otpModel, availability: .otpExpectedBySameUser)
    }
    
    public func sendSMSOTPV1(
        phoneNumber: String,
        clientID: String,
        clientOS: ClientOS,
        userID: String? = nil,
        _ req: Request
    ) async throws -> SMSOTPModel.V1 {
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
            phoneNumber: phoneNumber,
            encryptedCode: encryptedCode,
            otpID: otpToken.tokenID,
            clientID: clientID,
            clientOS: clientOS.rawValue)
        
        try await sms.send(to: phoneNumber, message: "Your code: \(code)")
        
        let createdAt = currentDate.timeIntervalSince1970
        let expireAt = currentDate.addingTimeInterval(TimeInterval(duration)).timeIntervalSince1970
        
        return .init(otpID: otpToken.tokenID, otpToken: otpToken.token, createdAt: createdAt, expireAt: expireAt)
    }
}

extension SMSOTPModel.V1: Content {}
