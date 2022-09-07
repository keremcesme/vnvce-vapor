//
//  File.swift
//  
//
//  Created by Kerem Cesme on 7.09.2022.
//

import Fluent
import Vapor

// MARK: MeController V1 - Methods -
extension MeController.V1 {
    
    func profileHandler(_ req: Request) async throws -> Response<User.Private> {
        let user = try req.auth.require(User.self)
        let privateProfile = try await user.convertToPrivate(req)
        
        return Response(result: privateProfile, message: "User private profile returned successfuly.")
    }
}
