//
//  File.swift
//  
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Fluent
import Vapor

// MARK: PostController V1 - Upload - Helper -
extension PostController.V1 {
    
    func postsQueryBuilder(userID: User.IDValue, _ req: Request) async throws -> Page<Post> {
        let payload = try req.content.decode(PostsPayload.V1.self)
        let query =  Post.query(on: req.db)
            .with(\.$owner)
            .join(parent: \.$owner)
            .with(\.$media)
        switch payload {
        case let .me(archived):
            query
                .group(.or) { group in
                    group
                        .filter(PostOwner.self, \.$owner.$id == userID)
                        .group(.and) { coPost in
                            coPost
                                .filter(\.$type == .coPost)
                                .filter(PostOwner.self, \.$coOwner.$id == userID)
//                                .filter(PostOwner.self, \.$approvalStatus == .approved)
                        }
                }
                .filter(\.$archived == archived)
        case let .user(userID):
            query
                .group(.or) { group in
                    group
                        .filter(PostOwner.self, \.$owner.$id == userID)
                        .group(.and) { coPost in
                            coPost
                                .filter(\.$type == .coPost)
                                .filter(PostOwner.self, \.$coOwner.$id == userID)
                                .filter(PostOwner.self, \.$approvalStatus == .approved)
                        }
                }
                .filter(\.$archived == false)
        }
        
        return try await query
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
    }
    
}
