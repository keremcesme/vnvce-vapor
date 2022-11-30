////
////  File.swift
////
////
////  Created by Kerem Cesme on 10.08.2022.
////
//
//import Vapor
//import SotoSNS
//
//protocol SMSSender {
//    func sendSMS(to phoneNumber: String, message: String, on eventLoop: EventLoop) async throws -> EventLoopFuture<Bool>
//    func sendSMS2(to phoneNumber: String, message: String, on eventLoop: EventLoop) async throws -> Bool
//}
//
//private struct SMSSenderKey: StorageKey {
//    typealias Value = SMSSender
//}
//
//extension Application {
//    var smsSender: SMSSender? {
//        get {
//            storage[SMSSenderKey.self]
//        }
//
//        set {
//            storage[SMSSenderKey.self] = newValue
//        }
//    }
//}
//
////extension Application {
////    var aws: AWS {
////        aws()
////    }
////
////    private func aws(_ client: AWSClient? = nil) -> AWS {
////        .init()
////    }
////}
////
////extension Application.AWS {
////    public mutating func configure(accessKeyID: String, secretAccessKey: String, senderId: String?) {
////
////        self.client = AWSClient(credentialProvider: .static(accessKeyId: accessKeyID, secretAccessKey: secretAccessKey), httpClientProvider: .createNew)
////    }
////}
//
//extension Application {
//
//    public func sendSMS(to phoneNumber: String, message: String) async throws {
//
//    }
//
//}
