//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor

struct Response<T: Content>: Content {
    var result: T?
    var message: String
    var code: HTTPStatus
    
    init(
        result: T? = nil,
        message: String,
        code: HTTPStatus
    ) {
        self.result = result
        self.message = message
        self.code = code
    }
}
