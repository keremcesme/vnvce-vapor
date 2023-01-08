
import Vapor
import VNVCECore

extension HTTPHeaders.Name {
    static let acceptVersion = HTTPHeaders.Name(VNVCEHeaders.acceptVersion)
    static let refreshToken = HTTPHeaders.Name(VNVCEHeaders.refreshToken)
    static let accessToken = HTTPHeaders.Name(VNVCEHeaders.accessToken)
    static let clientID = HTTPHeaders.Name(VNVCEHeaders.clientID)
    static let clientOS = HTTPHeaders.Name(VNVCEHeaders.clientOS)
    static let accessTokenID = HTTPHeaders.Name(VNVCEHeaders.accessTokenID)
    static let refreshTokenID = HTTPHeaders.Name(VNVCEHeaders.refreshTokenID)
    static let authID = HTTPHeaders.Name(VNVCEHeaders.authID)
    static let userID = HTTPHeaders.Name(VNVCEHeaders.userID)
    static let otpID = HTTPHeaders.Name(VNVCEHeaders.otpID)
}

extension HTTPHeaders {
    public var acceptVersion: String? {
        get {
            guard let string = self.first(name: .acceptVersion) else {
                return nil
            }
            return string
        }
        set {
            if let acceptVersion = newValue {
                replaceOrAdd(name: .acceptVersion, value: acceptVersion)
            } else {
                remove(name: .acceptVersion)
            }
        }
    }
    
    public var refreshToken: String? {
        get {
            guard let string = self.first(name: .refreshToken) else {
                return nil
            }
            return string
        }
        set {
            if let refreshToken = newValue {
                replaceOrAdd(name: .refreshToken, value: refreshToken)
            } else {
                remove(name: .refreshToken)
            }
        }
    }
    
    public var accessToken: String? {
        get {
            guard let string = self.first(name: .accessToken) else {
                return nil
            }
            return string
        }
        set {
            if let accessToken = newValue {
                replaceOrAdd(name: .accessToken, value: accessToken)
            } else {
                remove(name: .accessToken)
            }
        }
    }
    
    public var clientID: String? {
        get {
            guard let string = self.first(name: .clientID) else {
                return nil
            }
            return string
        }
        set {
            if let clientID = newValue {
                replaceOrAdd(name: .clientID, value: clientID)
            } else {
                remove(name: .clientID)
            }
        }
    }
    
    public var clientOS: String? {
        get {
            guard let string = self.first(name: .clientOS) else {
                return nil
            }
            return string
        }
        set {
            if let clientOS = newValue {
                replaceOrAdd(name: .clientOS, value: clientOS)
            } else {
                remove(name: .clientOS)
            }
        }
    }
    
    public var accessTokenID: String? {
        get {
            guard let string = self.first(name: .accessTokenID) else {
                return nil
            }
            return string
        }
        set {
            if let accessTokenID = newValue {
                replaceOrAdd(name: .accessTokenID, value: accessTokenID)
            } else {
                remove(name: .accessTokenID)
            }
        }
    }
    
    public var refreshTokenID: String? {
        get {
            guard let string = self.first(name: .refreshTokenID) else {
                return nil
            }
            return string
        }
        set {
            if let refreshTokenID = newValue {
                replaceOrAdd(name: .refreshTokenID, value: refreshTokenID)
            } else {
                remove(name: .refreshTokenID)
            }
        }
    }
    
    public var authID: String? {
        get {
            guard let string = self.first(name: .authID) else {
                return nil
            }
            return string
        }
        set {
            if let authID = newValue {
                replaceOrAdd(name: .authID, value: authID)
            } else {
                remove(name: .authID)
            }
        }
    }
    
    public var userID: String? {
        get {
            guard let string = self.first(name: .userID) else {
                return nil
            }
            return string
        }
        set {
            if let userID = newValue {
                replaceOrAdd(name: .userID, value: userID)
            } else {
                remove(name: .userID)
            }
        }
    }
    
    public var otpID: String? {
        get {
            guard let string = self.first(name: .otpID) else {
                return nil
            }
            return string
        }
        set {
            if let otpID = newValue {
                replaceOrAdd(name: .otpID, value: otpID)
            } else {
                remove(name: .otpID)
            }
        }
    }
    
}
