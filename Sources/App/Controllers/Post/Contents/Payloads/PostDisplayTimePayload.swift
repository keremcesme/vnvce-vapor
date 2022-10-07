//
//  File.swift
//  
//
//  Created by Kerem Cesme on 7.10.2022.
//

import Vapor

final class PostDisplayTimePayload {
    struct V1: Content {
        let postID: UUID
        let postDisplayTimeID: UUID?
        let second: Double
    }
}
