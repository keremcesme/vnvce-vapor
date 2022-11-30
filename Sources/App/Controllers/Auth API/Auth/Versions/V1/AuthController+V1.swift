//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController V1 - Routes -
extension AuthController {
    
    final class V1 {
        static let shared = V1()
        
        public let version = APIVersion.v1
        
        init(){}
        
        private let authenticator = AccessToken.authenticator()
        private let middleware = User.guardMiddleware()
        
//        private let createAccount = CreateAccount.shared
//        private let login = Login.shared
        
        func routes(_ routes: RoutesBuilder) {
            routes.group("api", "\(version)", "auth") { authRoute in
//                createAccount.routes(
//                    routes: authRoute,
//                    auth: authenticator,
//                    guard: middleware)
                
//                login.routes(
//                    routes: authRoute,
//                    auth: authenticator,
//                    guard: middleware)
                
            }
        }
    }
    
}
