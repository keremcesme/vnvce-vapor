//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Fluent
import Vapor

// MARK: MeController V1 - Routes -
extension MeController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersions.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
        private let edit = Edit.shared
        
        func routes(_ routes: RoutesBuilder) {
            routes.group(authenticator, middleware) { secureRoute in
                secureRoute.group("api", "\(version)", "me") { meRoute in
                    edit.routes(
                        routes: meRoute,
                        auth: authenticator,
                        guard: middleware)
                    
    //                login.routes(
    //                    routes: authRoute,
    //                    auth: authenticator,
    //                    guard: middleware)
                    
                }
            }
            
        }
        
    }
}
