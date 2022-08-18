//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

struct Tokens: Content {
    let accessToken: String
    let refreshToken: String
}
