//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor
import Fluent

// MARK: Auth Controller V1 - Username - Helpers
extension AuthController {
    func checkUsernameAvailabilityV1(
        username: String,
        clientID: UUID,
        _ req: Request
    ) async throws -> UsernameAvailability {
        guard try await Username.query(on: req.db)
            .filter(\.$username == username)
            .first() == nil else {
            return .alreadyTaken
        }
        
        var reservedUsernames = try await ReservedUsername.query(on: req.db)
            .filter(\.$username == username)
            .sort(\.$createdAt, .descending)
            .all()
        
        if !reservedUsernames.isEmpty, let lastUsername = reservedUsernames.first {
            reservedUsernames.removeFirst()
            
            try await reservedUsernames.delete(force: true, on: req.db)
            
            guard lastUsername.expiresAt < Date() else {
                let id = lastUsername.clientID
                if id == clientID {
                    try await lastUsername.delete(force: true, on: req.db)
                    return .available
                } else {
                    return .reserved
                }
            }
            try await lastUsername.delete(force: true, on: req.db)
            return.available
        } else {
            return .available
        }
    }
    
    func reserveUsernameV1(
        username: String,
        clientID: UUID,
        _ req: Request
    ) async throws -> ReserveUsernameResult {
        let availability = try await checkUsernameAvailabilityV1(
            username: username,
            clientID: clientID,
            req)
        
        switch availability {
            case .alreadyTaken:
                return .failure(.alreadyTaken)
            case .reserved:
                return .failure(.reserved)
            case .available:
                
                let reservedUsername = ReservedUsername(
                    username: username,
                    clientID: clientID,
                    expiresAt: Date().addingTimeInterval(120))
                
                try await reservedUsername.create(on: req.db)
                
                return .success
        }
    }
    
}
