//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Fluent
import Vapor

// MARK: PostController V1 - Methods -
extension PostController.V1 {
    
    func uploadPostHandler(_ req: Request) async throws -> Response<Post.V1> {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let payload = try req.content.decode(UploadPostPayload.V1.self)
        
        
        let post: Post.V1 = try await req.db.transaction {
            
            // POST OWNER
            let ownerResult = try await self.createPostOwner(
                user: user,
                coOwnerID: payload.coOwnerID,
                on: $0)
            
            let ownerID = ownerResult.id
            let owner = ownerResult.owner
            
            // POST
            let postResult = try await self.createPost(
                payload: payload,
                ownerID: ownerID,
                on: $0)
            
            let postID = postResult.id
            let post = postResult.post
            
            // POST MEDIA
            let media = try await self.createPostMedia(
                postID: postID,
                userID: userID,
                media: payload.media,
                on: $0)
            
            return try post.convertV1(owner: owner, media: media)
        }
        
        return Response(result: post, message: "Post is uploaded")
    }
    
    func postsHandler(_ req: Request) async throws -> PaginationResponse<Post.V1> {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        let result = try await Post.query(on: req.db)
            .with(\.$owner)
            .join(parent: \.$owner)
            .with(\.$media)
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
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
        
        let posts = try await result.items.convertPosts(on: req.db)
        
        let pagination = Pagination(items: posts, metadata: result.metadata)
        
        return PaginationResponse(result: pagination, message: "Posts returned successfully.")
    }
    
}

