//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Vapor

final class MomentsPayload {
    enum V1: Content {
        case me
        case user(userID: UUID)
    }
}
