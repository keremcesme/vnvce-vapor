//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Fluent
import Vapor
import JWT
import VNVCECore

extension AuthController.CreateAccountController {
    struct V1: RouteCollection {
        private let endpoint = Endpoint.shared.routes.auth
        private let version = VNVCECore.APIVersion.v1
        
        public func boot(routes: RoutesBuilder) throws {
            
            
            let checkGroup = routes
                .grouped(endpoint.check.path.toPathComponents)
            
            checkGroup
                .on(endpoint.check.phoneNumber, use: checkPhoneNumber)
            
            checkGroup
                .on(endpoint.check.username, use: autoCheckUsernameHandler)
            
//            let route = routes.grouped("\(version)")
//
//            let phoneRoute = route.grouped("phone")
//            let usernameRoute = route.grouped("username")
//
//            // MARK: Step 1 - Check phone number availability ✅
//            phoneRoute.post("check", use: checkPhoneNumber)
//
//            // MARK: Step 2 - Auto check username availability ✅
//            usernameRoute.post("check", use: autoCheckUsernameHandler)
//
//            // MARK: Step 3 - Reserve username for 2 min and send OTP to phone.
//            route.post("reserve-username-send-otp", use: reserveUsernameAndSendOTPHandler)
//
//            route.post("create_account", use: createAccount)
            
//            route
//                .grouped(CreateAccountMiddleware())
//                .get("verify-jwt", use: verifyJWT)
            
        }
    }
}
