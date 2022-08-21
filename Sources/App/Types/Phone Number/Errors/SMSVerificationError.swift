//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class SMSVerificationError {
    // MARK: V1
    enum V1: String, Content {
        case expired = "expired"
        case failure = "failure"
    }
    // ...
}
