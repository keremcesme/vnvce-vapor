//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor

protocol SMSSender {
    func sendSMS(to phoneNumber: String, message: String, on eventLoop: EventLoop) async throws -> EventLoopFuture<Bool>
}

private struct SMSSenderKey: StorageKey {
    typealias Value = SMSSender
}

extension Application {
    var smsSender: SMSSender? {
        get {
            storage[SMSSenderKey.self]
        }
        
        set {
            storage[SMSSenderKey.self] = newValue
        }
    }
}
