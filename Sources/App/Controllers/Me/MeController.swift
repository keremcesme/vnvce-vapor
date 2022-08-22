//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Fluent
import Vapor

// MARK: MeController - Version Routes -
struct MeController: RouteCollection {
    
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        v1.routes(routes)
    }
}

