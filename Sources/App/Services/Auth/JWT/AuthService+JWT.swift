
import Vapor

extension AuthService {
    public struct JWT {
        private let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

extension AuthService.JWT {
    public var v1: AuthService.JWT.V1 {
        .init(self.app)
    }
}
