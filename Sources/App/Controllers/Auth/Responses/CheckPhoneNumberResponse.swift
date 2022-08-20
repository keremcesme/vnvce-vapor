//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.08.2022.
//

import Vapor

extension AuthController {
    
    struct CheckPhoneNumberResponseV1: Content {
        let status: PhoneNumberAvailability
    }
}
