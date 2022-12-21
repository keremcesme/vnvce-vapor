
import Vapor

extension AuthService {
    public struct OTP {
        private let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

extension AuthService.OTP {
    public var v1: AuthService.OTP.V1 {
        .init(self.app)
    }
}
