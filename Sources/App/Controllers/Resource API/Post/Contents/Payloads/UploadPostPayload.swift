//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.09.2022.
//

import Vapor

final class UploadPostPayload {
    
    // MARK: V1
    struct V1: Content {
        let description: String?
        let media: PostMediaPayload.V1
        let type: PostType
        let coOwnerID: UUID?
        
        init(description: String? = nil,
             media: PostMediaPayload.V1,
             type: PostType,
             coOwnerID: UUID? = nil
        ) {
            self.description = description
            self.media = media
            self.type = type
            self.coOwnerID = coOwnerID
        }
    }
}
