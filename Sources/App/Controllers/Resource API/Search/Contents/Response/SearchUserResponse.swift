//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Vapor
import FluentKit

final class SearchUserResponse {
    // MARK: V1
    struct V1: Content {
        let users: [User.Public]
        let metadata: PageMetadata
    }
}
