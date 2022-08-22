//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Fluent
import Vapor

// MARK: MeController V1 - Edit - Routes -
extension MeController.V1 {
    
    final class Edit {
        static let shared = Edit()
        
        init(){}
        
        func routes(
            routes: RoutesBuilder,
            auth authenticator: Authenticator,
            guard middleware: Middleware
        ) {
            routes.group("edit") { editRoute in
                
                // MARK: Profile Picture
                editRoute
                    .put("profile_picture", ":url", ":name", use: editProfilePictureHandler)
                editRoute
                    .delete("profile_picture", use: deleteProfilePictureHandler)
                
                // MARK: Display Name
                editRoute
                    .patch("display_name", ":value", use: editDisplayNameHandler)
                editRoute
                    .delete("display_name", use: deleteDisplayNameHandler)
                
                // MARK: Biography
                editRoute
                    .patch("biography", ":value", use: editBiographyHandler)
                editRoute
                    .delete("biography", use: deleteBiographyHandler)
            }
        }
    }
}
