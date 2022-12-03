
import Vapor
import JWT
import JWTDecode
import Redis
import RediStack

struct TokenJWTAuthenticator: AsyncBearerAuthenticator {
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        
        let decodedJWT = try request.jwt.decode(bearer.token)
        
        if let type = decodedJWT["token_type"].string,
            TokenClaims.TokenType(rawValue: type) == .access,
           let refreshTokenID = decodedJWT["refresh_token_id"].string {
            
            let refreshTokenActiveState = try await request.redis.get(.init("refresh_tokens:\(refreshTokenID)"), asJSON: RedisTokenPayloadOLD.self)
            
            if refreshTokenActiveState!.isActive {
                let accessTokenActiveState = try await request.redis.get(.init("access_tokens:\(decodedJWT.identifier!)"), asJSON: RedisTokenPayloadOLD.self)
                
                if accessTokenActiveState!.isActive {
                    let jwt = try request.jwt.verify(bearer.token, as: TokenClaims.V1.self)
                    guard let user = try await User.find(try jwt.userID.uuid(), on: request.db) else {
                        throw Abort(.notFound)
                    }
                    
                   request.auth.login(user)
                }
                
            }
            
        } else {
            throw Abort(.unauthorized)
        }
        
        return
    }
}

struct TokenJWTAuthenticator2: AsyncJWTAuthenticator {
    func authenticate(jwt: TokenClaims.V1, for request: Vapor.Request) async throws {
//        print(request.version)
    }
    
    typealias Payload = TokenClaims.V1
    
}
