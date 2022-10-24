//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Vapor


final class UploadMomentPayload {
    
    // MARK: V1
    struct V1: Content {
        let type: MediaType
        let name: String
        let url: String
        let thumbnailURL: String?
    }
}
