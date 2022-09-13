//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.09.2022.
//

import Foundation

enum MediaType: String, Codable {
    case image, movie
     
    static let schema =  "media_type"
}
