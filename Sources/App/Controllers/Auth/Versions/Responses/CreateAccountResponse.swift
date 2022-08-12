//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

extension AuthController {
    
    enum CreateAccountStatusV1: Content {
        case success(UserModel)
        case failure(SMSVerificationResult)
    }
    
    struct CreateAccountResponseV1: Content {
        let status: CreateAccountStatusV1
    }
}
