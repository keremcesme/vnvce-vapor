//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Fluent
import Vapor

// MARK: PostController - Version Routes -
struct PostController: RouteCollection {
    
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        v1.routes(routes)
    }
}
