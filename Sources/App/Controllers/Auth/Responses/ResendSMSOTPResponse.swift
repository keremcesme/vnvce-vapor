//
//  File.swift
//  
//
//  Created by Kerem Cesme on 20.08.2022.
//

import Vapor

extension AuthController {
    
    struct ResendSMSOTPResponseV1: Content {
        let status: SendSMSOTPAttempt
    }
}
