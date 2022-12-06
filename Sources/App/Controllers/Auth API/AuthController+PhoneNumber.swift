
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
            let p = try req.content.decode(CheckPhoneNumberPayload.V1.self)
            let result = try await checkPhoneNumberV1(payload: p, req)
            let availability = result.availability
            let description = availability.description
            if availability == .notUsed || availability == .otpExpectedBySameUser {
                return .init(ResultResponse.V1(error: false, description: description))
            } else {
                return .init(ResultResponse.V1(error: true, description: description))
            }
        default:
            throw Abort(.notFound)
        }
    }
    
    public func checkPhoneNumberV1(payload: CheckPhoneNumberPayload.V1, _ req: Request) async throws -> PhoneNumberAvailability.V1 {
        let p = payload
        
        let phoneQuery = try await PhoneNumber.query(on: req.db)
            .filter(\.$phoneNumber == p.phoneNumber)
            .first()
        
        guard phoneQuery == nil else {
            return .init(availability: .exist)
        }
        
        let key = RedisKey("phone_number:\(p.phoneNumber)")
        
        let otpAttemptQuery = try await req.redis.get(key, asJSON: RedisOTPModel.V1.self)
        
        if let otpAttempt = otpAttemptQuery {
            if try Bcrypt.verify(p.clientID, created: otpAttempt.encryptedClientID) {
                let otp = SMSOTPModel.V1(createdAt: otpAttempt.createdAt, expireAt: otpAttempt.expireAt)
                
                return .init(otp: otp, availability: .otpExpectedBySameUser)
            } else {
                return .init(availability: .otpExpected)
            }
        }
        return .init(availability: .notUsed)
    }
    
    public func sendSMSOTPV1(
        phoneNumber: String,
        clientID: String,
        _ req: Request
    ) async throws -> SMSOTPModel.V1 {
        let currentDate = Date()
        
        let symmetricKey = SymmetricKey(size: .bits128)
        let totp = TOTP(key: symmetricKey, digest: .sha256, digits: .six, interval: 60)
        let code = totp.generate(time: currentDate)
        
        let encryptedCode = try Bcrypt.hash(code)
        let encryptedClientID = try Bcrypt.hash(clientID)
        
        let otp = RedisOTPModel.V1(encryptedCode: encryptedCode, encryptedClientID: encryptedClientID)
        
        let key = RedisKey("phone_number:\(phoneNumber)")
        
        try await req.redis.setex(key, toJSON: otp, expirationInSeconds: 60)
        
//        try await req.application.sms.send(to: phoneNumber, message: "Your code: \(code)")
        
        return .init(createdAt: otp.createdAt, expireAt: otp.expireAt)
    }
    
}

extension SMSOTPModel.V1: Content {}
