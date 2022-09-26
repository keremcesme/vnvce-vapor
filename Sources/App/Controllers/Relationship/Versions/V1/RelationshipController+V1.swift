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
            routes.group(authenticator, middleware) { secureRoute in
                secureRoute.group("api", "\(version)", "relationship") { relationshipRoute in
                    relationshipRoute.get("fetch", ":user_id", use: relationshipHandler)
                    relationshipRoute.group("friend", configure: friendRoutes)
                    relationshipRoute.group("user", configure: userRoutes)
                }
            }
        }
        
        private func friendRoutes(_ route: RoutesBuilder) {
            route.group("request", configure: friendRequestRoutes)
            route.delete("remove", use: removeFriendHandler)
        }
        
        private func friendRequestRoutes(_ route: RoutesBuilder) {
            route.post("send", ":user_id", use: sendFriendRequestHandler)
            route.post("accept", use: acceptFriendRequestHandler)
            route.delete("undo_or_reject", use: undoOrRejectFriendRequestHandler)
        }
        
        private func userRoutes(_ route: RoutesBuilder) {
            route.post("block", ":user_id", use: blockUserHandler)
            route.delete("unblock", use: unblockUserHandler)
        }
        
    }
}
