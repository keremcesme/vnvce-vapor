
import Vapor
import JWT
import JWTDecode

extension Request.JWT {
    
    @discardableResult
    public func decode(_ token: String) throws -> JWT {
        try JWTDecode.decode(jwt: token)
    }
    
}
