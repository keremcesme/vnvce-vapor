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
                        .get("fetch", ":user_id", use: relationshipHandler)
                    
                    relationshipRoute.group("friend") { friendRoute in
                        friendRoute.group("request") { requestRoute in
                            requestRoute
                                .post("send", ":user_id", use: sendFriendRequestHandler)
                            requestRoute
                                .delete("undo_or_reject", ":request_id", use: undoOrRejectFriendRequestHandler)
                            
                            requestRoute
                                .post("accept", ":user_id", ":request_id", use: acceptFriendRequestHandler)
                        }
                        
                        friendRoute
                            .delete("remove", ":friendship_id", use: removeFriendHandler)
                    }
                    
                    relationshipRoute.group("user") { userRoute in
                        userRoute
                            .post("block", ":user_id", use: blockUserHandler)
                        userRoute
                            .delete("unblock", ":block_id", use: unblockUserHandler)
                    }
                    
                    
                }
            }
            
        }
        
    }
}
