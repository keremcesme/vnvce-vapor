//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class AccountResult {
    // MARK: V1
    struct V1: Content {
        let user: User.Private
        let tokens: Tokens
    }
}
