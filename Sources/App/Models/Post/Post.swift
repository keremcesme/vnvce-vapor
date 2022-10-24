//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor
import Foundation

final class Post: Model, Content {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: PostOwner
    
    @OptionalField(key: "description")
    var description: String?
    
    @OptionalChild(for: \.$post)
    var media: PostMedia?
    
    @Enum(key: "post_type")
    var type: PostType
    
    @Children(for: \.$post)
    var displayTime: [PostDisplayTime]
    
    @Field(key: "archived")
    var archived: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init(){}
    
    init(
        ownerID: PostOwner.IDValue,
        type: PostType,
        description: String? = nil,
        archived: Bool = false
    ){
        self.$owner.id = ownerID
        self.type = type
        self.description = description
        self.archived = archived
    }
    
    struct V1: Content {
        let id: UUID
        let description: String?
        let owner: PostOwner.V1
        let media: PostMedia.V1
        let type: PostType
        let totalWatchTime: Int
        let displayTime: PostDisplayTime.V1?
        let archived: Bool
        let createdAt: TimeInterval
        let modifiedAt: TimeInterval
    }
}

extension Post {
    func convertV1(owner: PostOwner.V1, media: PostMedia.V1) throws -> Post.V1 {
        guard let createdAt = self.createdAt?.timeIntervalSince1970,
              let modifiedAt = self.modifiedAt?.timeIntervalSince1970
        else {
            throw NSError(domain: "", code: 1)
        }

        return Post.V1(id: try self.requireID(),
                       description: self.description,
                       owner: owner,
                       media: media,
                       type: self.type,
                       totalWatchTime: 0,
                       displayTime: nil,
                       archived: self.archived,
                       createdAt: createdAt,
                       modifiedAt: modifiedAt)
    }
    
    func convertPost(userID: User.IDValue, on db: Database) async throws -> Post.V1 {
        guard let createdAt = self.createdAt?.timeIntervalSince1970,
              let modifiedAt = self.modifiedAt?.timeIntervalSince1970,
              let media = self.media?.convertPostMedia()
        else {
            throw NSError(domain: "", code: 1)
        }
        
        let postOwner = try await self.owner.convertPostOwner(db: db)
        
        let totalWatchTime = try await PostDisplayTime.query(on: db)
            .filter(\.$post.$id == self.requireID())
            .sum(\.$second)
        
        let displayTime = try await PostDisplayTime.query(on: db)
            .filter(\.$owner.$id == userID)
            .filter(\.$post.$id == self.requireID())
            .first()
        
        return Post.V1(
            id: try self.requireID(),
            description: self.description,
            owner: postOwner,
            media: media,
            type: self.type,
            totalWatchTime: Int(totalWatchTime ?? 0),
            displayTime: try displayTime?.convertDisplayTime(),
            archived: self.archived,
            createdAt: createdAt,
            modifiedAt: modifiedAt)
        
    }
    
}

extension Array where Element: Post {
    func convertPosts(userID: User.IDValue,on db: Database) async throws -> [Post.V1] {
        var posts = [Post.V1]()
        
        for post in self {
            let result = try await post.convertPost(userID: userID, on: db)
            posts.append(result)
        }
        
        return posts
    }
}


