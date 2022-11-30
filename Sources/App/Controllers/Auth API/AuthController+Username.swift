
import Vapor
import Fluent
import RediStack
import Redis
import VNVCECore

extension AuthController {
    public func checkUsernameHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let p = try req.content.decode(CheckUsernamePayload.V1.self)
            let availability = try await checkUsernameV1(payload: p, req)
            let description = availability.description
            if availability == .notUsed || availability == .reservedBySameUser {
                return .init(ResultResponse.V1(error: false, description: description))
            } else {
                return .init(ResultResponse.V1(error: true, description: description))
            }
        default:
            throw Abort(.notFound)
        }
    }
    
    public func checkUsernameV1(payload: CheckUsernamePayload.V1, _ req: Request) async throws -> UsernameAvailability.V1 {
        let p = payload
        
        guard p.username.validateUsername() else {
            return .invalidFormat
        }
        
        let usernameQuery = try await Username.query(on: req.db)
            .filter(\.$username == p.username)
            .first()
        
        guard usernameQuery == nil else {
            return .used
        }
        
        let key = RedisKey("reserved:\(p.username)")
        
        let reservedUsername = try await req.redis.get(key, asJSON: RedisReservedUsernameModel.V1.self)
        
        if let reservedUsername {
            if reservedUsername.clientID == p.clientID {
                return .reservedBySameUser
            } else {
                return .reserved
            }
        }
        
        return .notUsed
    }
    
    public func reserveUsernameV1(
        username: String,
        clientID: String,
        availabiltiy: UsernameAvailability.V1,
        _ req: Request
    ) async throws {
        guard availabiltiy == .notUsed || availabiltiy == .reservedBySameUser else {
            throw Abort(.notAcceptable)
        }
        
        let usernameKey = RedisKey("reserved:\(username)")
        
        if availabiltiy == .notUsed {
            let payload = RedisReservedUsernameModel.V1(clientID: clientID)
            try await req.redis.setex(usernameKey, toJSON: payload, expirationInSeconds: 120)
        }
        
        if availabiltiy == .reservedBySameUser {
            _ = req.redis.expire(usernameKey, after: .seconds(120))
        }
        
        return
    }
}
