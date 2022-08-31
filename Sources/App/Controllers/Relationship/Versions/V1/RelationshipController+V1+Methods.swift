//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

// MARK: RelationshipController V1 - Methods -
extension RelationshipController.V1 {
    
    func sendFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
    func acceptFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
     
        return .ok
    }
    
    func rejectFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
    func undoFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
    func blockUserHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
    func unblockUserHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
    func removeFriendHandler(_ req: Request) async throws -> HTTPStatus {
        
        return .ok
    }
    
}
