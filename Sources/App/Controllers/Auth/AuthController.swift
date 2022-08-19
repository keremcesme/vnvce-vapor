//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        v1routes(routes: routes)
    }
}

extension AuthController {
    
    func v1routes(routes: RoutesBuilder) {
        routes.group("api", "\(APIVersions.v1)", "auth") { auth in
            
            auth.group("create") { create in
                
                create.group("phone") { phone in
                    // Step 1 - Check phone number availability.
                    phone.get("check", ":phone_number", ":client_id", use: checkPhoneNumberHandlerV1)
                    phone.post("resend_otp", use: resendSMSOTPHandlerV1)
                }
                
                create.group("username") { username in
                    // Auto - Check username availabiltiy.
                    username.get("check", ":username", ":client_id", use: autoCheckUsernameHandlerV1)
                }
                
                // Step 2 - Reserve Username and Send OTP code to phone number.
                create.post("reserve_username_and_send_otp", use: reserveUsernameAndSendSMSOTPHandlerV1)
                
                // Step 3 - Verify OTP and create account.
                create.post("new_account", use: createAccountHandlerV1)
                
            }
            
            auth.group("login") { login in
                
            }
            
        }
    }
    
}
