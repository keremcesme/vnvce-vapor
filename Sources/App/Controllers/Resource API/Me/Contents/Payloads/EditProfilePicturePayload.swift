//
//  File.swift
//  
//
//  Created by Kerem Cesme on 23.08.2022.
//

import Vapor

final class EditProfilePicturePayload {
    
    // MARK: V1
    struct V1: Content {
        let url: String
        let name: String
        let alignment: ProfilePictureAlignmentType
    }
}
