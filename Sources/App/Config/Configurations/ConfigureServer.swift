
import Vapor

extension Application {
    
    func configureServer() {
        self.http.server.configuration.supportPipelining = true
        self.http.server.configuration.responseCompression = .enabled
        self.http.server.configuration.requestDecompression = .enabled
        self.http.server.configuration.tcpNoDelay = true
        
        switch self.environment {
        case .production:
            self.logger.notice("[ MODE ] Running in Production")
        default:
            self.logger.notice("[ MODE ] Running in Development")
        }
        
    }
}
