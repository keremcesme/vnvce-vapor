//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController - AUTH API
/// Here are all the routes for authorization.
///
/// - parameters:
///     - auth: vnvce.com/api/auth
///         - create: vnvce.com/api/auth/create
///         - login: vnvce.com/api/auth/login
///         - token: vnvce.com/api/auth/token

struct AuthController: RouteCollection {
    
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        let createController = CreateAccountController()
        let create = auth.grouped("create")
        try create.register(collection: createController)
        
        let loginController = LoginAccountController()
        let login = auth.grouped("login")
        try login.register(collection: loginController)
        
        
//        v1.routes(routes)
        
    }
}
