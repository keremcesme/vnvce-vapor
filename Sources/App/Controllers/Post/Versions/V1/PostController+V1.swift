//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Fluent
import Vapor

// MARK: PostController V1 - Route -
extension PostController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersions.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        func routes(_ routes: RoutesBuilder) {
            routes.group(authenticator, middleware) { secureRoute in
                secureRoute.group("api", "\(version)", "post") { postRoute in
                    postRoute.post("upload", use: uploadPostHandler)
                    
                    postRoute.get("fetch_posts", use: postsHandler)
                }
            }
        }
    }
}
