//
//  File.swift
//  
//
//  Created by Kerem Cesme on 25.09.2022.
//

import Fluent
import Vapor

// MARK: UserController V1 - Methods -
//extension UserController.V1 {
//    func profileHandler(_ req: Request) async throws -> Response<User.Public> {
//        _ = try req.auth.require(User.self)
//        
//        guard let userIDString = req.parameters.get("user_id") else {
//            throw Abort(.notFound, reason: "'user_id' paramter is missing.")
//        }
//        
//        let userID = userIDString.convertUUID
//        
//        guard let user = try await User.find(userID, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found.")
//        }
//        
//        let publicUser = try await user.convertToPublic(req.db)
//        
//        return Response(result: publicUser, message: "Public User returned succesfully.")
//    }
//    
//    
//    
//}
