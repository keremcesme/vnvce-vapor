//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Fluent
import Vapor

// MARK: RelationshipController V1 - Methods - Helpers
extension RelationshipController.V1 {
    
    // MARK: Target User
    // User
    func findTargetUser(_ req: Request) async throws -> User {
        guard let userIDStr = req.parameters.get("user_id") else {
            throw Abort(.notFound, reason: "'user_id' parameter is missing.")
        }
        
        let userID = userIDStr.convertUUID
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        return user
    }
    // User ID
    func findTargetUserID(_ req: Request) async throws -> User.IDValue {
        guard let userIDStr = req.parameters.get("user_id") else {
            throw Abort(.notFound, reason: "'user_id' parameter is missing.")
        }
        
        let userID = userIDStr.convertUUID
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        
        return try user.requireID()
    }
    // User ID - Friendship:
    // Finds the target user id from `Friendship`.
    func findTargetUserIDFromFriendship(
        userID: User.IDValue,
        friendship: Friendship
    ) throws -> User.IDValue {
        return try {
            if userID == friendship.$user1.$id.value {
                guard let targetUserID = friendship.$user2.$id.value else {
                    throw Abort(.notFound, reason: "Target User ID not found.")
                }
                return targetUserID
            } else if userID == friendship.$user2.$id.value {
                guard let targetUserID = friendship.$user1.$id.value else {
                    throw Abort(.notFound, reason: "Target User ID not found.")
                }
                return targetUserID
            } else {
                throw Abort(.notFound, reason: "Target User ID not found.")
            }
        }()
    }
    
    // MARK: Friend Request
    // Friend Request
    func findFriendRequest(_ req: Request) async throws -> FriendRequest {
        guard let requestIDString = req.parameters.get("request_id") else {
            throw Abort(.notFound, reason: "'request_id' parameter is missing.")
        }
        
        let requestID = requestIDString.convertUUID
        
        guard let request = try await FriendRequest.find(requestID, on: req.db) else {
            throw Abort(.notFound, reason: "Request not found.")
        }
        
        return request
        
    }
    // Friend Request - v2
    func findFriendRequest(ids: [User.IDValue], _ db: Database) async throws -> FriendRequest? {
        try await FriendRequest.query(on: db)
            .filter(\.$user.$id ~~ ids)
            .filter(\.$submittedUser.$id ~~ ids)
            .first()
    }
    // Friend Request ID
    func findFriendRequestID(_ req: Request) async throws -> FriendRequest.IDValue {
        guard let requestIDString = req.parameters.get("request_id") else {
            throw Abort(.notFound, reason: "'request_id' parameter is missing.")
        }
        
        let requestID = requestIDString.convertUUID
        
        guard let request = try await FriendRequest.find(requestID, on: req.db) else {
            throw Abort(.notFound, reason: "Request not found.")
        }
        
        return try request.requireID()
    }
    // Friend Request ID - Friendship:
    // Finds the `FriendRequestID` from `Friendship`.
    func findTargetUserIDFromFriendRequest(
        userID: User.IDValue,
        request: FriendRequest
    ) throws -> User.IDValue {
        guard let targetUserID = request.$user.$id.value else {
            throw Abort(.notFound, reason: "Target User ID not found.")
        }
        return targetUserID
    }
    
    // MARK: Block
    // Block
    func findBlock(_ req: Request) async throws -> Block {
        guard let blockIDString = req.parameters.get("block_id") else {
            throw Abort(.notFound, reason: "'block_id' parameter is missing.")
        }
        
        let blockID = blockIDString.convertUUID
        
        guard let block = try await Block.find(blockID, on: req.db) else {
            throw Abort(.notFound, reason: "Block not found.")
        }
        
        return block
    }
    // Block - v2
    func findBlock(ids: [User.IDValue], _ req: Request) async throws -> Block? {
        try await Block.query(on: req.db)
            .filter(\.$user.$id ~~ ids)
            .filter(\.$blockedUser.$id ~~ ids)
            .first()
    }
    
    // MARK: Friendship
    // Friendship
    func findFriendship(_ req: Request) async throws -> Friendship {
        guard let friendshipIDString = req.parameters.get("friendship_id") else {
            throw Abort(.notFound, reason: "'friendship_id' parameter is missing.")
        }
        
        let friendshipID = friendshipIDString.convertUUID
        
        guard let friendship = try await Friendship.find(friendshipID, on: req.db) else {
            throw Abort(.notFound, reason: "Friendship not found.")
        }
        
        return friendship
    }
    // Friendship - v2
    func findFriendship(ids: [User.IDValue], _ db: Database) async throws -> Friendship? {
        try await Friendship.query(on: db)
            .filter(\.$user1.$id ~~ ids)
            .filter(\.$user2.$id ~~ ids)
            .first()
    }
}

extension RelationshipController.V1 {
    // MARK: Block Status
    func checkBlockStatus(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        _ req: Request
    ) async throws -> Relationship.V1? {
        let IDs: [User.IDValue] = [userID, targetUserID]
        let query = try await findBlock(ids: IDs, req)
//        let query = try await Block.query(on: req.db)
//            .group(.or) { group in
//                group
//                    .group(.and) { user in
//                        user
//                            .filter(\.$user.$id == userID)
//                            .filter(\.$blockedUser.$id == targetUserID)
//                    }
//                    .group(.and) { targetUser in
//                        targetUser
//                            .filter(\.$user.$id == targetUserID)
//                            .filter(\.$blockedUser.$id == userID)
//                    }
//            }
//            .first()
        
        guard let query = query else {
            return nil
        }
        return query.convertRelationship(userID)
    }
    
    // MARK: Friend Request Status
    func checkFriendRequestStatus(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        _ req: Request
    ) async throws -> Relationship.V1? {
        let IDs: [User.IDValue] = [userID, targetUserID]
        let query = try await FriendRequest.query(on: req.db)
            .filter(\.$user.$id ~~ IDs)
            .filter(\.$submittedUser.$id ~~ IDs)
//            .group(.or) { group in
//                group
//                    .group(.and) { user in
//                        user
//                            .filter(\.$user.$id == userID)
//                            .filter(\.$submittedUser.$id == targetUserID)
//                    }
//                    .group(.and) { targetUser in
//                        targetUser
//                            .filter(\.$user.$id == targetUserID)
//                            .filter(\.$submittedUser.$id == userID)
//                    }
//            }
            .first()
        
        guard let query = query else {
            return nil
        }
        
        return query.convertRelationship(userID)
    }
    
    // MARK: Friendship Status
    func checkFriendshipStatus(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        _ req: Request
    ) async throws -> Relationship.V1 {
        let IDs: [User.IDValue] = [userID, targetUserID]
        let query = try await Friendship.query(on: req.db)
            .filter(\.$user1.$id ~~ IDs)
            .filter(\.$user2.$id ~~ IDs)
//            .group(.or) { group in
//                group
//                    .group(.and) { user in
//                        user
//                            .filter(\.$user1.$id == userID)
//                            .filter(\.$user2.$id == targetUserID)
//                    }
//                    .group(.and) { targetUser in
//                        targetUser
//                            .filter(\.$user1.$id == targetUserID)
//                            .filter(\.$user2.$id == userID)
//                    }
//            }
            .first()
        
        guard query != nil else {
            return .nothing
        }
        
        return .friend
    }
    
    // MARK: Check Relationship
    func checkRelationship(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        _ req: Request
    ) async throws -> Relationship.V1 {
        if let blockStatus = try await checkBlockStatus(
            userID: userID,
            targetUserID: targetUserID,
            req) {
            return blockStatus
        }
        
        if let requestStatus = try await checkFriendRequestStatus(
            userID: userID,
            targetUserID: targetUserID, req) {
            return requestStatus
        }
        
        let friendshipStatus = try await checkFriendshipStatus(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        return friendshipStatus
    }
    
    // MARK: Check Relationship Before Action
    // Before entering the relationship interaction, when the request reaches the server, it checks whether the existing relationship is valid.
    func checkRelationshipBeforeAction(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        _ req: Request
    ) async throws {
        let currentRelationship = try req.content.decode(Relationship.V1.self)
        
        let relationship = try await checkRelationship(
            userID: userID,
            targetUserID: targetUserID,
            req)
        
        guard currentRelationship == relationship else {
            throw Abort(.badRequest, reason: "")
        }
    }
    
    // MARK: Block User Helper
    // Before the user blocks a user, it clears any relationship between them.
    func blockUserHelper(
        userID: User.IDValue,
        targetUserID: User.IDValue,
        relationship: Relationship.V1,
        _ db: Database
    ) async throws {
        let IDs: [User.IDValue] = [userID, targetUserID]
        switch relationship {
        case .nothing:
            return
        case .friend:
            try await findFriendship(ids: IDs, db)?.delete(force: true, on: db)
//            try await Friendship.query(on: db)
//                .group(.or) { group in
//                    group
//                        .group(.and) { user in
//                            user
//                                .filter(\.$user1.$id == userID)
//                                .filter(\.$user2.$id == targetUserID)
//                        }
//                        .group(.and) { targetUser in
//                            targetUser
//                                .filter(\.$user1.$id == targetUserID)
//                                .filter(\.$user2.$id == userID)
//                        }
//                }
//                .delete(force: true)
        case .friendRequestSubmitted, .friendRequestReceived:
            try await findFriendRequest(ids: IDs, db)?.delete(force: true, on: db)
//            try await FriendRequest.query(on: db)
//                .group(.or) { group in
//                    group
//                        .group(.and) { user in
//                            user
//                                .filter(\.$user.$id == userID)
//                                .filter(\.$submittedUser.$id == targetUserID)
//                        }
//                        .group(.and) { targetUser in
//                            targetUser
//                                .filter(\.$user.$id == targetUserID)
//                                .filter(\.$submittedUser.$id == userID)
//                        }
//                }
//                .delete(force: true)
        case .blocked, .targetUserBlocked:
            throw Abort(.badRequest, reason: "Target user is already blocked the requested user.")
        }
    }
}
