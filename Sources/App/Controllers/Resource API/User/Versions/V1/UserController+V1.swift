//
//  File.swift
//  
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Fluent
import Vapor

// MARK: UserController V1 - Routes -
//extension UserController {
//    
//    final class V1 {
//        static let shared = V1()
//
//        public let version = APIVersion.v1
//
//        init() {}
//
//        private let authenticator = AccessToken.authenticator()
//        private let middleware = User.guardMiddleware()
//
//        func routes(_ routes: RoutesBuilder) {
//            routes.group(authenticator, middleware) { secureRoute in
//                secureRoute.group("api", "\(version)", "user") { userRoute in
//                    userRoute.post("profile", ":user_id", use: profileHandler)
//                }
//
//            }
//        }
//    }
//}
