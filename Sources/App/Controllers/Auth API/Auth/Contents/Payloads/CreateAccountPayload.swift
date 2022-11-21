//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class CreateAccountPayload {
    //MARK: V1
    struct V1: Content {
        let otp: VerifySMSPayload.V1
        let username: String
    }
}
