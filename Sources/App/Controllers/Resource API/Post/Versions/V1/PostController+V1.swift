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
        
        public let version = APIVersion.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        func routes(_ routes: RoutesBuilder) {
            routes.group(authenticator, middleware) { secureRoute in
                secureRoute.group("api", "\(version)", "post") { postRoute in
                    postRoute.post("upload", use: uploadPostHandler)
                    
                    postRoute.post("fetch_posts", use: postsHandler)
                    
                    postRoute.put("set_display_time", use: setPostDisplayTimeHandler)
                }
            }
        }
    }
}
