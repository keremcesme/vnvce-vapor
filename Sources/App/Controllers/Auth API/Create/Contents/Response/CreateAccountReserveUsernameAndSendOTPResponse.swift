//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    struct ReserveUsernameAndSendOTPResponse: Content {
        let token: String?
        let error: Bool?
        var message: String
        
        init(_ result: Result) {
            self.message = ""
            switch result {
            case let .token(value):
                self.token = value
                self.error = nil
            case .error:
                self.error = true
                self.token = nil
            }
        }
        
        enum Result {
            case token(_ value: String)
            case error
        }
    }
}
