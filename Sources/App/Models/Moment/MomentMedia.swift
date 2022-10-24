//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import Vapor

final class MomentMedia: Model, Content {
    static let schema = "moment_media_details"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "moment_id")
    var moment: Moment
    
    @Enum(key: "media_type")
    var mediaType: MediaType
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "thumbnail_url")
    var thumbnailURL: String?
    
    @Field(key: "sensitive_content")
    var sensitiveContent: Bool
    
    init(){}
    
    init(
        momentID: Moment.IDValue,
        mediaType: MediaType,
        name: String,
        url: String,
        thumbnailURL: String? = nil,
        sensitiveContent: Bool = false
    ){
        self.$moment.id = momentID
        self.mediaType = mediaType
        self.name = name
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.sensitiveContent = sensitiveContent
    }
    
    struct V1: Content {
        let mediaType: MediaType
        let sensitiveContent: Bool
        let name: String
        let url: String
        let thumbnailURL: String?
    }
    
}

extension MomentMedia {
    func convert() -> MomentMedia.V1 {
        return MomentMedia.V1(mediaType: self.mediaType,
                              sensitiveContent: self.sensitiveContent,
                              name: self.name,
                              url: self.url,
                              thumbnailURL: self.thumbnailURL)
    }
}
