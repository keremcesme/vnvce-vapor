
import Vapor
import Redis
import Queues
import QueuesRedisDriver

extension Application {
    
    private struct RedisCredentialsModel: Decodable {
        static let schema = "REDIS_CREDENTIALS"
        
        let host: String
        let port: Int
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.host = try container.decode(String.self, forKey: CodingKeys.host)
            self.port = Int(try container.decode(String.self, forKey: CodingKeys.port))!
        }
        
        enum CodingKeys: String, CodingKey {
            case host = "HOST"
            case port = "PORT"
        }
    }
    
    func configureRedis() async throws {
        self.logger.notice("[ 3/8 ] Configuring Redis")
        
        switch self.environment {
        case .production:
            let credentials = try await self.aws.secrets.getSecret(RedisCredentialsModel.schema, to: RedisCredentialsModel.self)
            
            self.redis.configuration = try RedisConfiguration(
                hostname: credentials.host,
                port: credentials.port)
            
            self.logger.notice("✅ Redis Configured")
            
        default:
            let configuration = try RedisConfiguration(hostname: "localhost")
            self.redis.configuration = configuration
            
//            self.queues.use(.redis(configuration))
//
//            try self.queues.startInProcessJobs()
//            try self.queues.startScheduledJobs()
            
            self.logger.notice("✅ Redis Configured")
        }
    }
}
