
import Fluent
import Vapor
import Redis
import RediStack
import JWT

extension AuthController.CreateAccountController.V1 {
    
    func testAPI(_ req: Request) async throws -> some Content {
        
        return Response(result: "", message: "")
    }
    
    public func checkPhoneNumber(_ req: Request)
    async throws -> AvailabilityResponse {
        let p = try req.content.decode(CheckPhonePayload.self)
        
        let availability = try await checkPhoneNumberAvailability(
            phone: p.phoneNumber,
            clientID: p.clientID,
            req)
        
        var result: AvailabilityResponse
        
        switch availability {
        case .otpExist, .alreadyTaken:
            result = .init(.error)
        case .available:
            result = .init(.available)
        }
        
        result.message = availability.message
        
        return result
    }
    
    public func autoCheckUsernameHandler(_ req: Request)
    async throws -> AvailabilityResponse {
        let p = try req.content.decode(CheckUsernamePayload.self)
        let availability = try await checkUsernameAvailability(
            username: p.username,
            clientID: p.clientID,
            phoneNumber: p.phoneNumber,
            req)
        
        var result: AvailabilityResponse
        
        switch availability {
        case .reserved, .alreadyTaken:
            result = .init(.error)
        case .available, .userHasAlreadyReserved:
            result = .init(.available)
        }
        
        result.message = availability.message
        
        return result
    }
    
    public func reserveUsernameAndSendOTPHandler(_ req: Request) async throws -> Response<String> {
        let p = try req.content.decode(ReserveUsernameAndSendOTPPayload.self)
        
        let usernameAvailability = try await checkUsernameAvailability(
            username: p.username,
            clientID: p.clientID,
            phoneNumber: p.phoneNumber,
            req)
        
        guard usernameAvailability == .available || usernameAvailability == .userHasAlreadyReserved else {
            throw Abort(.notFound)
        }
        
        let currentDate = Date()
        let usernameExp: TimeInterval = 120
        let otpExp: TimeInterval = 61
        
        // Username
        let usernameKey = RedisKey("reserved_\(p.username)")

        if usernameAvailability == .available {
            let redisPayload = RedisReservedUsernameModel.V1(
                clientID: p.clientID)
            
            try await req.redis.setex(usernameKey, toJSON: redisPayload, expirationInSeconds: 120)
        }
        
        if usernameAvailability == .userHasAlreadyReserved {
            _ = req.redis.expire(usernameKey, after: .seconds(Int64(usernameExp)))
        }
        
        // OTP
        let symmetricKey = SymmetricKey(size: .bits128)
        let totp = TOTP(key: symmetricKey, digest: .sha256, digits: .six, interval: Int(otpExp))
        let code = totp.generate(time: currentDate)
        
        return Response(result: "OK", message: "")
    }
    
    public func createAccount(_ req: Request) async throws -> HTTPStatus {
        guard let bearer = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }

        
//        let p = try req.content.decode(OTPTestPayload.self)
//        let jwt = try req.jwt.verify(bearer, as: OTPJWTPayload.self)
//
//
//        let reservedUsername = try await req.redis.get(RedisKey(p.username), asJSON: RedisReservedUsernameModel.V1.self)
//
//        let reservedUsernamePhone = reservedUsername!.reserver
//
//        let phoneNumber = try Bcrypt.verify(reservedUsernamePhone, created: jwt.encryptedPhoneNumber)
//
//        guard phoneNumber else {
//            print("decryption phone number failed")
//            return .unauthorized
//        }
//
//        let otp = try await req.redis.get(RedisKey(reservedUsernamePhone), asJSON: RedisOTPModel.V1.self)
//
//        let decryptedJti = try Bcrypt.verify(jwt.jti.value, created: otp!.encryptedJti)
//
//        guard decryptedJti else {
//            print("decryption jti failed")
//            return .unauthorized
//        }
//
//        guard jwt.clientID == otp!.clientID else {
//            print("client ids not match")
//            return .unauthorized
//        }
//
//        let decryptedCode = try Bcrypt.verify(p.code, created: otp!.encryptedCode)
//
//        guard decryptedCode else {
//            print("decryption code failed")
//            return .unauthorized
//        }
//
//        print("SUCCESSSSSSSSSSSSSS ✅")
        
        return .ok
    }
    
}

struct OTPTestPayload: Content {
    let username: String
    let code: String
}
