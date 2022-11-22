//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Fluent
import Vapor

extension AuthController.CreateAccountController {
    struct V2: RouteCollection {
        private let version = APIVersion.v2
        
        func boot(routes: RoutesBuilder) throws {
            _ = routes.grouped("\(version)")
            
        }
    }
}
