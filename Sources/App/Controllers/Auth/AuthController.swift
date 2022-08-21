//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController - Authentication Routes -
struct AuthController: RouteCollection {
    private let authenticator = AccessToken.authenticator()
    private let middleware = User.guardMiddleware()
    
    // NAME: AuthControllerV1
    private let v1 = V1.shared
    
    func boot(routes: RoutesBuilder) throws {
//        v1routes(routes: routes)
        
        v1.routes(routes)
        
    }
}






extension AuthController {
    
    
    
    
//    func v1routes(routes: RoutesBuilder) {
//        let tokenAuthMiddleware = AccessToken.authenticator()
//        let userGuardMiddleware = User.guardMiddleware()
//
//        routes.group("api", "\(v1.version)", "auth") { auth in
//
//            auth.group("create") { create in
//
//                create.group("phone") { phone in
//                    // Step 1 - Check phone number availability.
//                    phone.get("check", ":phone_number", ":client_id", use: checkPhoneNumberHandlerV1)
//                    phone.post("resend_otp", use: resendSMSOTPHandlerV1)
//                }
//
//                create.group("username") { username in
//                    // Auto - Check username availabiltiy.
//                    username.get("check", ":username", ":client_id", use: autoCheckUsernameHandlerV1)
//                }
//
//                // Step 2 - Reserve Username and Send OTP code to phone number.
//                create.post("reserve_username_and_send_otp", use: reserveUsernameAndSendSMSOTPHandlerV1)
//
//                // Step 3 - Verify OTP and create account.
//                create.post("new_account", use: createAccountHandlerV1)
//
//                // Optional Steps
//                create.group(tokenAuthMiddleware, userGuardMiddleware) { update in
//                    // Step 4 - Set Profile Picture.
//                    update.post("set_profile_picture", use: profilePictureHandlerV1)
//                    // Step 5 - Set Display Name.
//                    update.patch("set_display_name", ":display_name", use: displayNameHandlerV1)
//                    // Step 6 - Set Biography.
//                    update.patch("set_biography", ":biography", use: biographyHandlerV1)
//                }
//            }
//
//            auth.group("login") { login in
//
//            }
//
//        }
//    }
    
}
