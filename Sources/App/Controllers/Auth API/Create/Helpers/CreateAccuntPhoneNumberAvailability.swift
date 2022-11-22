//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Vapor

extension AuthController.CreateAccountController.V1 {
    
    enum PhoneNumberAvailability {
        case available
        case alreadyTaken
        case otpExist
        
        var message: String {
            switch self {
            case .available:
                return "Phone number is available."
            case .alreadyTaken:
                return "The phone number is already in use."
            case .otpExist:
                return "Waiting for an OTP verification for this phone number."
            }
        }
    }
    
}
