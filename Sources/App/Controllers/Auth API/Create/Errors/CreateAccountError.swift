//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    enum CreateAccountError: Error, Content {
        // Phone Number Errors:
        case otpExist
        case alreadyTaken
        
    }
}


