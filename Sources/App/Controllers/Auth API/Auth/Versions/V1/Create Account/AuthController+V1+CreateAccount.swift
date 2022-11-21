//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController V1 - Create Account - Routes -
extension AuthController.V1 {
    
    final class CreateAccount {
        static let shared = CreateAccount()
        
        init(){}
        
        func routes(
            routes: RoutesBuilder,
            auth authenticator: Authenticator,
            guard middleware: Middleware
        ) {
            routes.group("create") { createRoute in
                
                createRoute.group("phone") { phoneRoute in
                    phoneRoute
                        .get("check", ":phone_number", ":client_id", use: checkPhoneNumberHandler)
                    phoneRoute
                        .post("resend_otp", use: resendSMSOTPHandler)
                }
                
                createRoute.group("username") { usernameRoute in
                    // Auto - Check username availabiltiy.
                    usernameRoute
                        .get("check", ":username", ":client_id", use: autoCheckUsernameHandler)
                }
                
                // Step 2 - Reserve Username and Send OTP code to phone number.
                createRoute
                    .post("reserve_username_and_send_otp", use: reserveUsernameAndSendSMSOTPHandler)
                
                // Step 3 - Verify OTP and create account.
                createRoute
                    .post("new_account", use: createAccountHandler)
            }
        }
    }
}

