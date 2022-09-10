//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Fluent
import Vapor

// MARK: SearchController - Version Routes -
struct SearchController: RouteCollection {
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        v1.routes(routes)
    }
}
