//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

final class SendSMSOTPResult {
    // MARK: V1
    enum V1: Content {
        case success(SMSOTPAttempt)
        case failure(SendSMSOTPError.V1)
    }
}

extension SendSMSOTPResult.V1 {
    func message(_ phoneNumber: String) -> String {
        switch self {
            case .success(_):
                return "SMS is Sended"
            case let .failure(error):
                return error.message(phoneNumber)
        }
    }
}



