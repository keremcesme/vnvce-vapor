////
////  File.swift
////  
////
////  Created by Buse tunçel on 31.08.2022.
////
//
//import Fluent
//import Vapor
//
//// MARK: RelationshipController V1 - Methods -
//
//// MARK: Fetch Relationship
//extension RelationshipController.V1 {
//    func relationshipHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let targetUserID = try await findTargetUserID(req)
//        
//        let relationship = try await checkRelationship(
//            userID: userID,
//            targetUserID: targetUserID,
//            req.db)
//        
//        return Response(result: relationship, message: relationship.message)
//    }
//}
//
//// MARK: Relationship Actions
//extension RelationshipController.V1 {
//    func sendFriendRequestHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let targetUserID = try await findTargetUserID(req)
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        try await checkRelationshipBeforeAction(
//            userID: userID,
//            targetUserID: targetUserID,
//            relationship: relationship,
//            req.db)
//        
//        let friendRequest = FriendRequest(user: userID, submittedUser: targetUserID)
//
//        try await friendRequest.create(on: req.db)
//        
//        let requestID = try friendRequest.requireID()
//        
//        let newRelationship: Relationship.V1 = .friendRequestSubmitted(requestID: requestID)
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//    
//    func undoOrRejectFriendRequestHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        let friendRequest = try await findFriendRequest(relationship: relationship, req)
//        
//        let targetUserID = try findTargetUserIDFromFriendRequest(userID: userID, request: friendRequest)
//        
//        try await checkRelationshipBeforeAction(
//            userID: userID,
//            targetUserID: targetUserID,
//            relationship: relationship,
//            req.db)
//        try await friendRequest.delete(force: true, on: req.db)
//        
//        let newRelationship: Relationship.V1 = .nothing
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//    
//    func acceptFriendRequestHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        let friendRequest = try await findFriendRequest(relationship: relationship, req)
//        
//        guard let targetUserID = friendRequest.$user.$id.value else {
//            throw Abort(.notFound, reason: "Target User ID not found.")
//        }
//        
//        try await checkRelationshipBeforeAction(
//            userID: userID,
//            targetUserID: targetUserID,
//            relationship: relationship,
//            req.db)
//        
//        let friendship = Friendship(user1: userID, user2: targetUserID)
//        
//        try await req.db.transaction{ transaction in
//            try await friendRequest.delete(force: true, on: transaction)
//            try await friendship.create(on: transaction)
//        }
//        
//        let friendshipID = try friendship.requireID()
//        
//        let newRelationship: Relationship.V1 = .friend(friendshipID: friendshipID)
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//    
//    func removeFriendHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        let friendship = try await findFriendship(relationship: relationship, req)
//        
//        let targetUserID = try findTargetUserIDFromFriendship(
//            userID: userID,
//            friendship: friendship)
//        
//        try await checkRelationshipBeforeAction(
//            userID: userID,
//            targetUserID: targetUserID,
//            relationship: relationship,
//            req.db)
//        
//        try await friendship.delete(force: true, on: req.db)
//        
//        let newRelationship: Relationship.V1 = .nothing
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//    
//    func blockUserHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        let userID = try req.auth.require(User.self).requireID()
//        let targetUserID = try await findTargetUserID(req)
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        
//        let blockID: Block.IDValue = try await req.db.transaction{ transaction in
//            try await self.forceBlockUser(
//                userID: userID,
//                targetUserID: targetUserID,
//                relationship: relationship,
//                transaction)
//            
//            let block = Block(user: userID, blockedUser: targetUserID)
//            
//            try await block.create(on: transaction)
//            
//            return try block.requireID()
//        }
//        
//        let newRelationship: Relationship.V1 = .blocked(blockID: blockID)
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//    
//    func unblockUserHandler(_ req: Request) async throws -> Response<Relationship.V1> {
//        _ = try req.auth.require(User.self)
//        let relationship = try req.content.decode(Relationship.V1.self)
//        
//        let block = try await findBlock(relationship: relationship, req)
//        
//        try await block.delete(force: true, on: req.db)
//        
//        let newRelationship: Relationship.V1 = .nothing
//        
//        return Response(result: newRelationship, message: newRelationship.message)
//    }
//}
