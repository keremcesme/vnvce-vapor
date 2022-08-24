//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor

final class SendSMSOTPError {
    // MARK: V1
    enum V1: String, Content {
        case alreadyTaken = "alreadyTaken"
        case otpExist = "otpExist"
        case notFound = "notFound"
    }
    // ...
}

extension SendSMSOTPError.V1 {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .otpExist:
                return "OTP code available. Please try again in a short while."
            case .alreadyTaken:
                return "The phone number \"\(phoneNumber)\" is already taken."
            case .notFound:
                return "Could not find a vnvce account associated with this phone number."
        }
    }
}
