//
//  File.swift
//  
//
//  Created by Kerem Cesme on 28.09.2022.
//

import Fluent
import Vapor

// MARK: PostController V1 - Helper -
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
        
//        let date = Date().startOfMonth
//        let date2 = Date().endOfMonth
//
//        print(date)
//        print(date2)
//        let date = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//
//        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
//        let startOfMonth = Calendar.current.date(from: comp)!
//
//        let timestamp = startOfMonth.timeIntervalSince1970
//
//        let start = dateFormatter.string(from: startOfMonth)
//
//
//
//        print(start)
//        var comps2 = DateComponents()
//        comps2.month = 1
//        comps2.day = -1
//        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
//        let end = dateFormatter.string(from: endOfMonth!)
//        print(end)
        
        return try await query
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
    }
    
    func setPostDisplayTime(userID: User.IDValue, req: Request) async throws -> PostDisplayTime.V1 {
        let payload = try req.content.decode(PostDisplayTimePayload.V1.self)
        
        if let displayTime = try await PostDisplayTime.find(payload.postDisplayTimeID, on: req.db) {
            displayTime.second = payload.second
            try await displayTime.update(on: req.db)
            return try displayTime.convertDisplayTime()
        } else {
            guard let post = try await Post.find(payload.postID, on: req.db) else {
                throw Abort(.notFound)
            }
            
            let postID = try post.requireID()
            
            let displayTime = PostDisplayTime(postID: postID, ownerID: userID, second: payload.second)
            
            try await post.$displayTime.create(displayTime, on: req.db)
            return try displayTime.convertDisplayTime()
        }
    }
    
}
