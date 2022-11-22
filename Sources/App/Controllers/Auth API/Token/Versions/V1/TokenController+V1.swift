//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor
import Fluent

// MARK: TokenController V1 - Routes -
extension TokenController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersion.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        func routes(_ routes: RoutesBuilder) {
            routes.group("api", "\(version)", "token") { tokenRoute in
                tokenRoute.post("generate", use: generate)
            }
        }
    }
}
