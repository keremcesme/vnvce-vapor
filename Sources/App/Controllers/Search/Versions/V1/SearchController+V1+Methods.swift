//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Fluent
import Vapor
import FluentSQL
import SQLKit


// MARK: SearchController V1 - Methods -
extension SearchController.V1 {
    
    func searchUserHandler(_ req: Request) async throws -> Response<SearchUserResponse.V1> {
        let userID = try req.auth.require(User.self).requireID()
        
        let queryTerm = try req.content.decode(String.self)
        
        let result = try await User.query(on: req.db)
            .join(child: \.$username)
//            .filter(\.$id, .notEqual, userID)
            .group(.or) { group in
                group
                    .filter(\.$displayName, .custom("ilike"), "%\(queryTerm)%")
                    .filter(Username.self, \Username.$username, .custom("ilike"), "%\(queryTerm)%")
            }
            .paginate(for: req)
        
        let publicUsers: [User.Public] = try await result.items.convertToPublic(req)
            
        return Response(result: SearchUserResponse.V1(users: publicUsers, metadata: result.metadata), message: "Users returned successfully.")
    }
}
