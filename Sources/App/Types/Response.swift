//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import FluentKit

struct Response<T: Content>: Content {
    var result: T?
    var message: String
    
    init(
        result: T? = nil,
        message: String
    ) {
        self.result = result
        self.message = message
    }
}

struct Pagination<T: Content>: Content {
    var items: T
    var metadata: PageMetadata
    
    init(items: T,
         metadata: PageMetadata = PageMetadata(page: 0, per: 0, total: 0)) {
        self.items = items
        self.metadata = metadata
    }
}

typealias PaginationResponse<T: Content> = Response<Pagination<T>>
