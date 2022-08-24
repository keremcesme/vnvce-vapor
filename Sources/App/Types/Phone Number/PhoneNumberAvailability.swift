//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor

typealias CheckPhoneNumberAvailabilityResult<T: Content> = (availability: T, attempt: SMSVerificationAttempt?)

final class PhoneNumberAvailability {
    
    // MARK: Create Account V1
    enum CreateV1: String, Content {
        case available = "available"
        case alreadyTaken = "alreadyTaken"
        case otpExist = "otpExist"
    }
    
    // MARK: Login V1
    enum LoginV1: String, Content {
        case available = "available"
        case notFound = "notFound"
        case otpExist = "otpExist"
    }
    
}

extension PhoneNumberAvailability.CreateV1 {
    
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

extension PhoneNumberAvailability.LoginV1 {
    
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .available:
                return "The phone number \"\(phoneNumber)\" is available."
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .notFound:
                return "Could not find a vnvce account associated with this phone number."
        }
    }
}
