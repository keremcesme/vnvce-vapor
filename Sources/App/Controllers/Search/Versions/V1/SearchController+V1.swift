//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Fluent
import Vapor

// MARK: SearchController V1 - Routes -
extension SearchController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersions.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        func routes(_ routes: RoutesBuilder) {
            routes.group(authenticator, middleware) { secureRoute in
                secureRoute.group("api", "\(version)", "search") { searchRoute in
                    searchRoute
                        .post("user", use: searchUserHandler)
                    
                }
            }
        }
    }
}
