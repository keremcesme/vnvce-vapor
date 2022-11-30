//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Fluent
import Vapor

// MARK: AUTH API - Create Account Versions
///
/// - parameters:
///     - v1: vnvce.com/api/auth/create/v1
///     - v2: vnvce.com/api/auth/create/v2
///     - ....

extension AuthController {
    struct CreateAccountController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            
            let collectionV1 = V1()
            try routes
                .register(collection: collectionV1)
            
            
        }
    }
}
