//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.09.2022.
//

import Fluent
import Vapor

final class PostMedia: Model, Content {
    static let schema = "post_media_details"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "post_id")
    var post: Post
    
    @Enum(key: "media_type")
    var mediaType: MediaType
    
    @Field(key: "sensitive_content")
    var sensitiveContent: Bool
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "thumbnail_url")
    var thumbnailURL: String?
    
    @Field(key: "storage_location")
    var storageLocation: UUID
    
    init(){}
    
    init(
        postID: Post.IDValue,
        mediaType: MediaType,
        sensitiveContent: Bool = false,
        name: String,
        url: String,
        thumbnailURL: String? = nil,
        storageLocation: UUID
    ){
        self.$post.id = postID
        self.mediaType = mediaType
        self.sensitiveContent = sensitiveContent
        self.name = name
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.storageLocation = storageLocation
    }
    
    struct V1: Content {
        let mediaType: MediaType
        let sensitiveContent: Bool
        let name: String
        let url: String
        let thumbnailURL: String?
        let storageLocation: UUID
        
        init(mediaType: MediaType,
             sensitiveContent: Bool,
             name: String,
             url: String,
             thumbnailURL: String? = nil,
             storageLocation: UUID) {
            self.mediaType = mediaType
            self.sensitiveContent = sensitiveContent
            self.name = name
            self.url = url
            self.thumbnailURL = thumbnailURL
            self.storageLocation = storageLocation
        }
    }
}

extension PostMedia {
    func convertV1() -> PostMedia.V1 {
        return PostMedia.V1(mediaType: self.mediaType,
                            sensitiveContent: self.sensitiveContent,
                            name: self.name,
                            url: self.url,
                            thumbnailURL: self.thumbnailURL,
                            storageLocation: self.storageLocation)
    }
    
    func convertPostMedia() -> PostMedia.V1 {
        return PostMedia.V1(mediaType: self.mediaType,
                            sensitiveContent: self.sensitiveContent,
                            name: self.name,
                            url: self.url,
                            thumbnailURL: self.thumbnailURL,
                            storageLocation: self.storageLocation)
    }
    
}
