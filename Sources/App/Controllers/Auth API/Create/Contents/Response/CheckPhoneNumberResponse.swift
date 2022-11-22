//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    struct AvailabilityResponse: Content {
        let available: Bool?
        let error: Bool?
        var message: String
        
        init(_ result: Result) {
            self.message = ""
            switch result {
            case .available:
                self.available = true
                self.error = nil
            case .error:
                self.error = true
                self.available = nil
            }
        }
        
        enum Result {
            case available
            case error
        }
    }
}
