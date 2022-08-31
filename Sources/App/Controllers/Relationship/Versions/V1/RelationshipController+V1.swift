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
                    relationshipRoute
                        .post("send", use: sendFriendRequestHandler)
                    relationshipRoute
                        .post("accept", use: acceptFriendRequestHandler)
                    relationshipRoute
                        .post("reject", use: rejectFriendRequestHandler)
                    relationshipRoute
                        .post("undo_request", use: undoFriendRequestHandler)
                    relationshipRoute
                        .post("block_user", use: blockUserHandler)
                    relationshipRoute
                        .post("unblock_user", use: unblockUserHandler)
                    relationshipRoute
                        .post("remove", use: removeFriendHandler)
                }
            }
            
        }
    }
}
