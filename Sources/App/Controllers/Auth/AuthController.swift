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
                    phone.get("check", ":phone_number", use: checkPhoneNumberHandlerV1)
                    // Step 3 - Send OTP code to phone number.
                    phone.post("send_otp", use: sendSMSOTPHandlerV1)
                }
                
                create.group("username") { username in
                    // Auto - Check username availabiltiy.
                    username.get("check", ":username", use: autoCheckUsernameHandlerV1)
                    // Step 2 - Check username availabiltiy and reserve username.
                    username.post("reserve", use: reserveUsernameHandlerV1)
                }
                
                // Step 4 - Verify OTP and create account.
                create.post("new_account", use: createAccountHandlerV1)
                
            }
            
            auth.group("login") { login in
                
            }
            
        }
    }
    
}
