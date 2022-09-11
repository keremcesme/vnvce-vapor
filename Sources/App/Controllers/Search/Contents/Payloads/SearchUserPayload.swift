//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.09.2022.
//

import Vapor

final class SearchUserPayload {
    // MARK: V1
    struct V1: Content {
        let term: String
    }
}
