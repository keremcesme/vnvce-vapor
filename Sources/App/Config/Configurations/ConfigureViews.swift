//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import Leaf

extension Application {
    public func configureViews() {
        self.logger.notice("[ 9/9 ] Configuring Views")
        
        self.routes.defaultMaxBodySize = "10mb"
        self.middleware.use(FileMiddleware(publicDirectory: self.directory.publicDirectory))
        self.views.use(.leaf)
        
        self.logger.notice("✅ Views Configured")
    }
}
