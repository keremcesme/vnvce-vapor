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
    func relationshipHandler(_ req: Request) async throws -> Response<Relationship.V1> {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try await findTargetUserID(req)
        
        let relationship = try await checkRelationship(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        return Response(result: relationship, message: relationship.rawValue)
    }
    
    // MARK: ACTIONs
    func sendFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try await findTargetUserID(req)
        
        try await checkRelationshipBeforeAction(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        let friendRequest = FriendRequest(user: userID, submittedUser: targetUserID)
        
        try await friendRequest.create(on: req.db)
        
        return .ok
    }
    
    func undoOrRejectFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        
        let request = try await findFriendRequest(req)
        
        let targetUserID = try findTargetUserIDFromFriendRequest(
            userID: userID,
            request: request)
        
        try await checkRelationshipBeforeAction(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        try await request.delete(force: true, on: req.db)
        
        return .ok
    }
    
    func acceptFriendRequestHandler(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try await findTargetUserID(req)
        
        try await checkRelationshipBeforeAction(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        let request = try await findFriendRequest(req)
        
        let friendship = Friendship(user1: userID, user2: targetUserID)
        
        try await req.db.transaction{ transaction in
            try await request.delete(force: true, on: transaction)
            try await friendship.create(on: transaction)
        }
        
        return .ok
    }
    
    func blockUserHandler(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try await findTargetUserID(req)
        
        let block = Block(user: userID, blockedUser: targetUserID)
        
        let relationship = try await checkRelationship(userID: userID,
                                                       targetUserID: targetUserID,
                                                       req)
        
        try await req.db.transaction{ transaction in
            try await self.blockUserHelper(
                userID: userID,
                targetUserID: targetUserID,
                relationship: relationship,
                transaction)
            try await block.create(on: transaction)
        }
        
        return .ok
    }
    
    func unblockUserHandler(_ req: Request) async throws -> HTTPStatus {
        _ = try req.auth.require(User.self)
        
        let block = try await findBlock(req)
        
        try await block.delete(force: true, on: req.db)
        
        return .ok
    }
    
    func removeFriendHandler(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        
        let friendship = try await findFriendship(req)
        
        let targetUserID = try findTargetUserIDFromFriendship(
            userID: userID,
            friendship: friendship)
        
        try await checkRelationshipBeforeAction(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        try await friendship.delete(force: true, on: req.db)
        
        return .ok
    }
    
}
