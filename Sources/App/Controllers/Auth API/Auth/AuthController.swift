//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController - Authentication Routes -
struct AuthController: RouteCollection {
    private let authenticator = AccessToken.authenticator()
    private let middleware = User.guardMiddleware()
    
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        
        v1.routes(routes)
        
    }
}
