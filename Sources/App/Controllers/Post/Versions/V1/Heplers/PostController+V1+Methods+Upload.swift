//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Fluent
import Vapor

// MARK: PostController V1 - Upload - Helper -
extension PostController.V1 {
    
    func createPostOwner(
        user: User,
        coOwnerID: UUID?,
        on db: Database
    ) async throws -> (id: PostOwner.IDValue, owner: PostOwner.V1) {
        let userID = try user.requireID()
        if let coOwner = try await User.find(coOwnerID, on: db) {
            let coOwnerID = try coOwner.requireID()
            let owner = PostOwner(owner: userID, coOwner: coOwnerID, approvalStatus: .pending)
            try await owner.create(on: db)
            
            let postOwnerID = try owner.requireID()
            let postOwner = try await owner.convertV1(owner: user, coOwner: coOwner, on: db)
            
            
            return (postOwnerID, postOwner)
        } else {
            let owner = PostOwner(owner: userID)
            try await owner.create(on: db)
            
            let postOwnerID = try owner.requireID()
            let postOwner = try await owner.convertV1(owner: user, on: db)
            
             return (postOwnerID, postOwner)
        }
    }
    
    func createPost(
        payload: UploadPostPayload.V1,
        ownerID: PostOwner.IDValue,
        on db: Database
    ) async throws -> (id: Post.IDValue, post: Post) {
        let post = Post(
            ownerID: ownerID,
            type: payload.type,
            description: payload.description)
        try await post.create(on: db)
        let postID = try post.requireID()
        
        return (postID, post)
    }
    
    func createPostMedia(
        postID: Post.IDValue,
        userID: User.IDValue,
        media: PostMediaPayload.V1,
        on db: Database
    ) async throws -> PostMedia.V1 {
        let postMedia = PostMedia(
            postID: postID,
            mediaType: media.type,
            name: media.name,
            url: media.url,
            thumbnailURL: media.thumbnailURL,
            storageLocation: userID)
        try await postMedia.create(on: db)
        return postMedia.convertV1()
    }
}
