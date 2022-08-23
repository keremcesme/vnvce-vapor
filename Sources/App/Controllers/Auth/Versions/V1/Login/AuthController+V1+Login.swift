//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController V1 - Login - Routes -
extension AuthController.V1 {
    
    final class Login {
        static let shared = Login()
        
        init(){}
        
        func routes(
            routes: RoutesBuilder,
            auth authenticator: Authenticator,
            guard middleware: Middleware
        ) {
            routes.group("login") { createRoute in
                
            }
        }
    }
}
