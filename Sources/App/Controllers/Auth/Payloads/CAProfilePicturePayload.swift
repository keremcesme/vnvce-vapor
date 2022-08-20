//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

extension AuthController {
    struct ProfilePicturePayloadV1: Content {
        let url: String
        let name: String
    }
}
