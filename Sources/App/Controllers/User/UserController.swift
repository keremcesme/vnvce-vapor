//
//  File.swift
//  
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Fluent
import Vapor

// MARK: UserController - Version Routes -
struct UserController: RouteCollection {
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        v1.routes(routes)
    }
}
