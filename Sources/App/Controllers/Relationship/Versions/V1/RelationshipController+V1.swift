//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

// MARK: RelationshipController V1 - Routes -
extension RelationshipController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersions.v1
        
        init() {}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        func routes(_ routes: RoutesBuilder) {
            routes.group(authenticator, middleware, configure: secureRoutes)
        }
        
        private func secureRoutes(_ route: RoutesBuilder) {
            // https://www.vnvce.com/api/v1/relationship/...
            route.group("api", "\(version)", "relationship", configure: relationshipRoutes)
        }
        
        // https://www.vnvce.com/api/v1/relationship/...
        private func relationshipRoutes(_ route: RoutesBuilder) {
            // https://www.vnvce.com/api/v1/relationship/fetch/user_id
            route.get("fetch", ":user_id", use: relationshipHandler)
            // https://www.vnvce.com/api/v1/relationship/friend/...
            route.group("friend", configure: friendRoutes)
            // https://www.vnvce.com/api/v1/relationship/user/...
            route.group("user", configure: userRoutes)
        }
        
        // https://www.vnvce.com/api/v1/relationship/friend/...
        private func friendRoutes(_ route: RoutesBuilder) {
            // https://www.vnvce.com/api/v1/relationship/friend/request/...
            route.group("request", configure: friendRequestRoutes)
            // https://www.vnvce.com/api/v1/relationship/friend/remove
            route.delete("remove", use: removeFriendHandler)
        }
        
        // https://www.vnvce.com/api/v1/relationship/friend/request/...
        private func friendRequestRoutes(_ route: RoutesBuilder) {
            // https://www.vnvce.com/api/v1/relationship/friend/request/send/user_id
            route.post("send", ":user_id", use: sendFriendRequestHandler)
            // https://www.vnvce.com/api/v1/relationship/friend/request/accept
            route.post("accept", use: acceptFriendRequestHandler)
            // https://www.vnvce.com/api/v1/relationship/friend/request/undo_or_reject
            route.delete("undo_or_reject", use: undoOrRejectFriendRequestHandler)
        }
        
        // https://www.vnvce.com/api/v1/relationship/user/...
        private func userRoutes(_ route: RoutesBuilder) {
            // https://www.vnvce.com/api/v1/relationship/user/block/user_id
            route.post("block", ":user_id", use: blockUserHandler)
            // https://www.vnvce.com/api/v1/relationship/user/unblock
            route.delete("unblock", use: unblockUserHandler)
        }
        
    }
}
