
import Vapor
import VNVCECore

extension Application {
    public var authService: AuthService {
        .init(self)
    }
}

extension Request {
    public var authService: AuthService {
        .init(self.application)
    }
}

public struct AuthService {
    private let app: Application
    
    init(_ app: Application) {
        self.app = app
    }
}

extension AuthService {
    public var jwt: AuthService.JWT {
        .init(self.app)
    }
    
    public var redis: AuthService.Redis {
        .init(self.app)
    }
    
    public var pkce: PKCEService {
        .init()
    }
    
    public var otp: AuthService.OTP {
        .init(self.app)
    }
    
    public var reservedUsername: AuthService.ReservedUsername {
        .init(self.app)
    }
}
