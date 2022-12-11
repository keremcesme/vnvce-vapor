
import Vapor

extension HTTPHeaders.Name {
    static let acceptVersion = HTTPHeaders.Name("Accept-version")
    static let refreshToken = HTTPHeaders.Name("X-Auth-Refresh-Token")
    static let clientID = HTTPHeaders.Name("X-Client-ID")
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
            if let version = newValue {
                replaceOrAdd(name: .acceptVersion, value: version)
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
            if let version = newValue {
                replaceOrAdd(name: .refreshToken, value: version)
            } else {
                remove(name: .refreshToken)
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
            if let version = newValue {
                replaceOrAdd(name: .clientID, value: version)
            } else {
                remove(name: .clientID)
            }
        }
    }
    
}
