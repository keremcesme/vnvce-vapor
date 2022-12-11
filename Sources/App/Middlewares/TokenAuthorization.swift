//
//  File.swift
//  
//
//  Created by Kerem Cesme on 20.11.2022.
//

import Vapor
import Fluent

struct TokenAuthMiddleware: AsyncMiddleware {
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
        guard
            let token = request.headers.bearerAuthorization?.token,
            let version = request.headers.acceptVersion
        else {
            print("Missing Header")
            return try await next.respond(to: request)
        }
        
        let jwtService = request.authService.jwt.v1
        
        try await jwtService.verify(token)
        
        return try await next.respond(to: request)
    }
}
