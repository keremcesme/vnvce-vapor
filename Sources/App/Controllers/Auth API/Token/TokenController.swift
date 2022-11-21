//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor
import JWT
// MARK: TokenController - Version Routes -
struct TokenController: RouteCollection {
    
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
        v1.routes(routes)
    }
}
