//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Vapor

protocol S3Protocol {
    func upload() async throws -> Bool
}

private struct S3Key: StorageKey {
    typealias Value = S3Protocol
}

extension Application {
    var s3: S3Protocol? {
        get {
            storage[S3Key.self]
        }
        
        set {
            storage[S3Key.self] = newValue
        }
    }
}
