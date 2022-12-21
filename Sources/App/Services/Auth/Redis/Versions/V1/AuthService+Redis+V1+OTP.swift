
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

public extension AuthService.Redis.V1 {
    typealias OTP = Redis.OTP.V1
    typealias OTPGetResult = RedisGetResult<OTP>
    
    func addOTP(phoneNumber: String, encryptedCode: String, otpID: String, clientID: String, clientOS: String, userID: String? = nil) async {
        let key = otpRedisBucket(phoneNumber)
        let payload = OTP(encryptedCode: encryptedCode, otpID: otpID, clientID: clientID, clientOS: clientOS, userID: userID)
        let ttl = TTL.otp
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    func getOTP(_ phoneNumber: String) async -> OTP? {
        let key = otpRedisBucket(phoneNumber)
        return try? await self.app.redis.get(key, asJSON: OTP.self)
    }
    
    func getOTPWithTTL(_ phoneNumber: String) async -> OTPGetResult? {
        let key = otpRedisBucket(phoneNumber)
        let payload = try? await self.app.redis.get(key, asJSON: OTP.self)
        let ttl = try? await self.app.redis.getTTL(key)
        guard let payload, let ttl else { return nil }
        return .init(payload, ttl: ttl)
    }
}
