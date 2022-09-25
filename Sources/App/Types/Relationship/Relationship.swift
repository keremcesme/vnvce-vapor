//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.09.2022.
//

import Vapor

final class Relationship {
    
    enum V1: Content, Equatable {
        case nothing
        case friend(friendshipID: UUID)
        case friendRequestSubmitted(requestID: UUID)
        case friendRequestReceived(requestID: UUID)
        case targetUserBlocked
        case blocked(blockID: UUID)
    }
    
}

extension Relationship.V1 {
    var message: String {
        switch self {
        case .nothing:
            return "Nothing"
        case let .friend(friendshipID):
            return "Friendship ID: \(friendshipID)"
        case let .friendRequestSubmitted(requestID):
            return "Request is submitted. RequestID: \(requestID)"
        case let .friendRequestReceived(requestID):
            return "Request is received. RequestID: \(requestID)"
        case .targetUserBlocked:
            return "Target user blocked."
        case let .blocked(blockID):
            return "Blocked: \(blockID)"
        }
    }
    
    var requestID: UUID? {
        switch self {
        case let .friendRequestSubmitted(requestID):
            return requestID
        case let .friendRequestReceived(requestID):
            return requestID
        default: return nil
        }
    }
    
    var friendshipID: UUID? {
        switch self {
        case let .friend(friendshipID):
            return friendshipID
        default: return nil
        }
    }
}
