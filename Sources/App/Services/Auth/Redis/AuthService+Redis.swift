
import Vapor

extension AuthService {
    public struct Redis {
        private let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

extension AuthService.Redis {
    public var v1: AuthService.Redis.V1 {
        .init(self.app)
    }
}
