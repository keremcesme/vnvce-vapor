
import Vapor
import JWTKit

extension Request.JWT {
    @discardableResult
    public func unverified<Payload>(_ message: String, as payload: Payload.Type = Payload.self) throws -> Payload where Payload: JWTPayload {
        try self.unverified([UInt8](message.utf8), as: Payload.self)
    }
    
    @discardableResult
    public func unverified<Message, Payload>(_ message: Message, as payload: Payload.Type = Payload.self) throws -> Payload
    where Message: DataProtocol, Payload: JWTPayload
    {
        try self._request.application.jwt.signers.unverified(message, as: Payload.self)
    }
}
