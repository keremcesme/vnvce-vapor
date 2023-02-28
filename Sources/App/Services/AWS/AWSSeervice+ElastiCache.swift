
import Vapor
import SotoElastiCache

extension Application.AWS {
    public var elastiCache: AWSConfiguration.ElastiCache {
        .init(self.configuration)
    }
}

extension AWSConfiguration {
    public struct ElastiCache {
        private var elastiCache: SotoElastiCache.ElastiCache?
        
        public init(_ config: AWSConfiguration?){
            if let config {
                self.elastiCache = .init(client: config.client, region: .eucentral1)
            } else {
                self.elastiCache = nil
            }
        }
        
        public func reboot() async throws {
            
        }
    }
}
