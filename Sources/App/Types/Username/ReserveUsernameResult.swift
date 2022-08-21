//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

//enum ReserveUsernameResult: Content {
//    case success
//    case failure(ReserveUsernameFailure)
//}

final class ReserveUsernameResult {
    
    // MARK: V1
    enum V1: Content {
        case success
        case failure(ReserveUsernameError.V1)
    }
}

extension ReserveUsernameResult.V1 {
    func message(_ username: String) -> String {
        switch self {
            case .success:
                return "Reserve success."
            case let .failure(error):
                return error.message(username)
        }
    }
}
