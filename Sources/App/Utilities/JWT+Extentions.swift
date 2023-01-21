
import Vapor
import JWTKit

extension Request.JWT {
    @discardableResult
    public func decode<Payload>(_ message: String, as payload: Payload.Type = Payload.self) throws -> Payload where Payload: JWTPayload {
        try self._request.application.jwt.signers.decode(message, as: Payload.self)
    }
    
//    @discardableResult
//    public func decode<Message, Payload>(_ message: Message, as payload: Payload.Type = Payload.self) throws -> Payload
//    where Message: DataProtocol, Payload: JWTPayload
//    {
//        try self._request.application.jwt.signers.unverified(message, as: Payload.self)
//    }
}

extension Application.JWT {
    @discardableResult
    public func decode<Payload>(_ message: String, as payload: Payload.Type = Payload.self) throws -> Payload where Payload: JWTPayload {
        try self.signers.decode(message, as: Payload.self)
//        try self.decode([UInt8](message.utf8), as: Payload.self)
    }
    
//    @discardableResult
//    public func decode<Message, Payload>(_ message: Message, as payload: Payload.Type = Payload.self) throws -> Payload
//    where Message: DataProtocol, Payload: JWTPayload
//    {
//        try self.signers.unverified(message, as: Payload.self)
//    }
}

extension JWTSigners {
    @discardableResult
    public func decode<Payload>(_ message: String, as payload: Payload.Type = Payload.self) throws -> Payload where Payload: JWTPayload {
        try self.decode([UInt8](message.utf8), as: Payload.self)
    }
    
    @discardableResult
    public func decode<Message, Payload>(_ message: Message, as payload: Payload.Type = Payload.self) throws -> Payload
    where Message: DataProtocol, Payload: JWTPayload
    {
        try self.unverified(message, as: Payload.self)
    }
}
