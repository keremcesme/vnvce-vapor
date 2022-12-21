
import Vapor

extension AuthService {
    public struct ReservedUsername {
        private let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

extension AuthService.ReservedUsername {
    public var v1: AuthService.ReservedUsername.V1 {
        .init(self.app)
    }
}
