//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.09.2022.
//

import Fluent
import Vapor

enum PostType: String, Codable {
    case single = "single"
    case coPost = "co_post"
    
    static let schema = "post_type"
}

enum CoPostApprovalStatus: String, Codable {
    case pending, approved, rejected
    
    static let schema = "co_post_approval_status"
}
