//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Foundation
import Vapor

final class SMSVerificationResult {
    // MARK: V1
    enum V1: String, Content {
        case verified = "verified"
        case expired = "expired"
        case failure = "failure"
    }
}


