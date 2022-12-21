
import Redis
import RediStack

fileprivate typealias TTL = Redis.TTL.V1

public extension AuthService.Redis.V1 {
    typealias ReservedUsername = Redis.ReservedUsername.V1
    typealias ReservedUsernameGetResult = RedisGetResult<ReservedUsername>
    
    func addUsername(username: String, clientID: String, clientOS: String) async {
        let key = reservedUsernameRedisBucket(username)
        let payload = ReservedUsername(clientID: clientID, clientOS: clientOS)
        let ttl = TTL.username
        try? await self.app.redis.setex(key, toJSON: payload, expirationInSeconds: ttl)
    }
    
    func getUsername(_ username: String) async -> ReservedUsername? {
        let key = reservedUsernameRedisBucket(username)
        return try? await self.app.redis.get(key, asJSON: ReservedUsername.self)
    }
    
    func deleteUsername(_ username: String) async {
        let key = reservedUsernameRedisBucket(username)
        await self.app.redis.drop(key)
    }
}
