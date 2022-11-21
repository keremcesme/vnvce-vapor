//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Fluent
import JWT

/*
    REFRESH TOKEN SCHEME
    "device_id:jtw_id" : "token"
 */

public func jwtPlayground(_ app: Application) throws {
    let jwt = app.grouped("jwt")
    
    jwt.get("get", use: jwtGET)
    jwt.post("verify", use: jwtVERIFY)
    
}

private func jwtGET(_ req: Request) async throws -> Vapor.Response {
    let payload = JWTExample(test: "Hello world!")
    
    let token = try req.jwt.sign(payload, kid: .private)
    
    
    
    var rsp = Vapor.Response(status: .ok)
    
    let cookie: (String, HTTPCookies.Value) = ("refresh_token", HTTPCookies.Value(
        string: "TOKEN",
        isSecure: false,
        isHTTPOnly: false,
        sameSite: .strict))
    
    rsp.headers.cookie = HTTPCookies(dictionaryLiteral: cookie)
    
    return rsp
}

private func jwtVERIFY(_ req: Request) async throws -> String {
    guard let token = req.headers.bearerAuthorization?.token else {
        throw Abort(.notFound)
    }
    
    let payload = try req.jwt.verify(token, as: JWTExample.self)
    
    
    return payload.test
}

struct JWTExample: JWTPayload {
    var test: String
    
    func verify(using signer: JWTSigner) throws {}
}


struct JWTExample2: JWTPayload {
    var userID: UUID
    var clientID: String
    
    var sub: SubjectClaim
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

struct RefreshTokenJWTPayload: JWTPayload {
    var uid: String
    var jti: IDClaim
    var iss: IssuerClaim
    var iat: IssuedAtClaim
    var sub: SubjectClaim
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}
