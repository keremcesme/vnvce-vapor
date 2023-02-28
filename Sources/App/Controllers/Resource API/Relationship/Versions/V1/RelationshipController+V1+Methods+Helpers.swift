
//
//import Fluent
//import Vapor
//
//// MARK: RelationshipController V1 - Methods - Helpers
//extension RelationshipController.V1 {
//    
//    // MARK: Target User
//    // User
//    func findTargetUser(_ req: Request)
//    async throws -> User {
//        guard let userIDStr = req.parameters.get("user_id") else {
//            throw Abort(.notFound, reason: "'user_id' parameter is missing.")
//        }
//        
//        let userID = userIDStr.convertUUID
//        
//        guard let user = try await User.find(userID, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found.")
//        }
//        
//        return user
//    }
//    // User ID
//    func findTargetUserID(_ req: Request)
//    async throws -> User.IDValue {
//        guard let userIDStr = req.parameters.get("user_id") else {
//            throw Abort(.notFound, reason: "'user_id' parameter is missing.")
//        }
//        
//        let userID = userIDStr.convertUUID
//        
//        guard let user = try await User.find(userID, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found.")
//        }
//        
//        return try user.requireID()
//    }
//    
//    // User ID - Friend Request:
//    // Finds the target user id from `Friend Request`.
//    func findTargetUserIDFromFriendRequest(userID: User.IDValue, request: FriendRequest)
//    throws -> User.IDValue {
//        let requestedUserID = request.$user.$id.value
//        let submittedUserID = request.$submittedUser.$id.value
//        
//        if userID == requestedUserID, let targetUserID = submittedUserID {
//            return targetUserID
//        } else if userID == submittedUserID, let targetUserID = requestedUserID {
//            return targetUserID
//        } else {
//            throw Abort(.notFound, reason: "Target User ID not found.")
//        }
//    }
//    
//    // User ID - Friendship:
//    // Finds the target user id from `Friendship`.
//    func findTargetUserIDFromFriendship(userID: User.IDValue, friendship: Friendship)
//    throws -> User.IDValue {
//        let user1_ID = friendship.$user1.$id.value
//        let user2_ID = friendship.$user2.$id.value
//
//        if userID == user1_ID {
//            guard let targetUserID = user2_ID else {
//                throw Abort(.notFound, reason: "Target User ID not found.")
//            }
//            return targetUserID
//        } else if userID == user2_ID {
//            guard let targetUserID = user1_ID else {
//                throw Abort(.notFound, reason: "Target User ID not found.")
//            }
//            return targetUserID
//        } else {
//            throw Abort(.notFound, reason: "Target User ID not found.")
//        }
//    }
//    
//    // MARK: Friend Request
//    // Friend Request
//    func findFriendRequest(relationship: Relationship.V1, _ req: Request)
//    async throws -> FriendRequest {
//        guard let requestID = relationship.requestID else {
//            throw Abort(.notFound, reason: "Content of request is not equal to 'Relationship.V1.friendRequestReceived' or 'Relationship.V1.friendRequestSubmitted'.")
//        }
//        
//        guard let request = try await FriendRequest.find(requestID, on: req.db) else {
//            throw Abort(.notFound, reason: "Request not found.")
//        }
//        
//        return request
//    }
//    
//    // MARK: Block
//    // Block
//    func findBlock(relationship: Relationship.V1, _ req: Request)
//    async throws -> Block {
//        guard let blockID = relationship.blockID else {
//            throw Abort(.notFound, reason: "Content of request is not equal to 'Relationship.V1.blocked'.")
//        }
//        
//        guard let block = try await Block.find(blockID, on: req.db) else {
//            throw Abort(.notFound, reason: "Block not found.")
//        }
//        
//        return block
//    }
//    
//    // MARK: Friendship
//    // Friendship
//    func findFriendship(relationship: Relationship.V1, _ req: Request)
//    async throws -> Friendship {
//        guard let friendshipID = relationship.friendshipID else {
//            throw Abort(.notFound, reason: "Content of request is not equal to 'Relationship.V1.friend'.")
//        }
//        
//        guard let friendship = try await Friendship.find(friendshipID, on: req.db) else {
//            throw Abort(.notFound, reason: "Friendship not found.")
//        }
//        
//        return friendship
//    }
//}
//
//extension RelationshipController.V1 {
//    // MARK: Block Status
//    func checkBlockStatus(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database )
//    async throws -> Relationship.V1? {
//        var query = try await Block.query(on: on)
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
//            .all()
//        
//        guard !query.isEmpty else {
//            return nil
//        }
//        
//        let first = query.first!
//        
//        query.removeFirst()
//        
//        if !query.isEmpty {
//            try await query.delete(force: true, on: on)
//        }
//        
//        return try first.convertRelationship(userID)
//    }
//    
//    // MARK: Friend Request Status
//    func checkFriendRequestStatus(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database)
//    async throws -> Relationship.V1? {
//        var query = try await FriendRequest.query(on: on)
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
//            .all()
//        
//        guard !query.isEmpty else {
//            return nil
//        }
//        
//        let first = query.first!
//        
//        query.removeFirst()
//        
//        if !query.isEmpty {
//            try await query.delete(force: true, on: on)
//        }
//        
//        return try first.convertRelationship(userID)
//    }
//    
//    // MARK: Friendship Status
//    func checkFriendshipStatus(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database)
//    async throws -> Relationship.V1 {
//        var query = try await Friendship.query(on: on)
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
//            .all()
//        
//        guard !query.isEmpty else {
//            return .nothing
//        }
//        
//        let first = query.first!
//        
//        query.removeFirst()
//        
//        if !query.isEmpty {
//            try await query.delete(force: true, on: on)
//        }
//        
//        let id = try first.requireID()
//        
//        return .friend(friendshipID: id)
//    }
//    
//    // MARK: Check Relationship
//    func checkRelationship(userID: User.IDValue, targetUserID: User.IDValue, _ on: Database)
//    async throws -> Relationship.V1 {
//        if let blockStatus = try await checkBlockStatus(
//            userID: userID,
//            targetUserID: targetUserID,
//            on) {
//            return blockStatus
//        }
//        
//        if let requestStatus = try await checkFriendRequestStatus(
//            userID: userID,
//            targetUserID: targetUserID, on) {
//            return requestStatus
//        }
//        
//        let friendshipStatus = try await checkFriendshipStatus(
//            userID: userID,
//            targetUserID: targetUserID,
//            on)
//        
//        return friendshipStatus
//    }
//    
//    // MARK: Check Relationship Before Action
//    // Before entering the relationship interaction, when the request reaches the server, it checks whether the existing relationship is valid.
//    func checkRelationshipBeforeAction(userID: User.IDValue, targetUserID: User.IDValue, relationship: Relationship.V1, _ on: Database)
//    async throws {
//        let checkedRelationship = try await checkRelationship(
//            userID: userID,
//            targetUserID: targetUserID,
//            on)
//        
//        guard relationship == checkedRelationship else {
//            throw Abort(.badRequest, reason: "burasi")
//        }
//    }
//    
//    // MARK: Block User Helper
//    // Before the user blocks a user, it clears any relationship between them.
//    func forceBlockUser(userID: User.IDValue, targetUserID: User.IDValue, relationship: Relationship.V1, _ on: Database)
//    async throws {
//        let checkedRelationship = try await checkRelationship(
//            userID: userID,
//            targetUserID: targetUserID,
//            on)
//        
//        try await forceBlockUserHelper(
//            relationship: relationship,
//            checkedRelationship: checkedRelationship,
//            on)
//    }
//    
//    func forceBlockUserHelper(relationship: Relationship.V1, checkedRelationship: Relationship.V1, _ on: Database)
//    async throws {
//        guard relationship == checkedRelationship else {
//            return try await deleteRelationship(relationship: checkedRelationship, on)
//        }
//        
//        try await deleteRelationship(relationship: relationship, on)
//    }
//    
//    func deleteRelationship(relationship: Relationship.V1, _ on: Database)
//    async throws {
//        switch relationship {
//        case let .friend(friendshipID):
//            try await Friendship.find(friendshipID, on: on)?.delete(force: true, on: on)
//        case let .friendRequestSubmitted(requestID):
//            try await FriendRequest.find(requestID, on: on)?.delete(force: true, on: on)
//        case let .friendRequestReceived(requestID):
//            try await FriendRequest.find(requestID, on: on)?.delete(force: true, on: on)
//        case .blocked(_):
//            throw Abort(.badRequest, reason: "User already blocked.")
//        default:
//            return
//        }
//        return
//    }
//}
