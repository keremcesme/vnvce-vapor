//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.11.2022.
//

import Fluent
import Vapor
import JWT

extension AuthController.CreateAccountController {
    struct V1: RouteCollection {
        private let version = APIVersion.v1
        
        func boot(routes: RoutesBuilder) throws {
            let route = routes
                .grouped("\(version)")
//                .grouped(FirstStepMiddleware())
            
            
            
            let phoneRoute = route.grouped("phone")
            let usernameRoute = route.grouped("username")
            
            // MARK: Step 1 - Check phone number availability ✅
            phoneRoute.post("check", use: checkPhoneNumber)

            // MARK: Step 2 - Auto check username availability ✅
            usernameRoute.post("check", use: autoCheckUsernameHandler)
            
            // MARK: Step 3 - Reserve username for 2 min and send OTP to phone.
            route.post("reserve-username-send-otp", use: reserveUsernameAndSendOTPHandler)
            
            route
                .grouped(CreateAccountMiddleware())
                .get("verify-jwt", use: verifyJWT)
            
        }
    }
}
