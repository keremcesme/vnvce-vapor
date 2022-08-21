//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

final class PhoneNumberAvailability {
    
    // MARK: V1
    enum V1: String, Content {
        case available = "available"
        case alreadyTaken = "alreadyTaken"
        case otpExist = "otpExist"
    }
    
}

extension PhoneNumberAvailability.V1 {
    
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .available:
                return "The phone number \"\(phoneNumber)\" is available."
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .alreadyTaken:
                return "The phone number \"\(phoneNumber)\" is already taken."
        }
    }
}
