//
//  File.swift
//  
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Foundation

enum ProfilePictureAlignmentType: String, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
    
    static let schema: String = "profile_picture_alignment_type"
}
