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
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("me")
        
        let edit = api.grouped("edit")
        edit.patch("display-name", use: editDisplayNameHandler)
        edit.patch("biography", use: editBiographyHandler)
        
    }
}

