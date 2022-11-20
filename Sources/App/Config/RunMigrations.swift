//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import FluentPostGIS

func runMigrations(_ app: Application) {
    app.migrations.add([
        // ENUMS - DATA TYPEs
//        EnablePostGISMigration(),
//        CreateProfilePictureAlignmentType(),
//        CreateCoPostApprovalStatus(),
//        CreateMediaType(),
//        CreateDeviceOS(),
//        CreateMonth(),
//        CreatePostType(),
        
        
        // AUTHENTICATION
//        CreateSMSVerificationAttempt(),
        
        // USERNAME
//        CreateReservedUsername(),
        
        // USER
//        CreateUser(),
//        CreateProfilePicture(),
//        CreatePhoneNumber(),
//        CreateUsername(),
//        CreateNotificationToken(),
        
        // AUTH TOKENS
//        CreateRefreshToken(),
//        CreateAccessToken(),
        
        // RELATIONSHIP
//        CreateFriendship(),
//        CreateFriendRequest(),
//        CreateBlock(),
        
        // POST
//        CreatePost(),
//        CreateMoment(),
        
        // EXTENSIONS
//        CreatePG_TRGMExtension(),
//        CreateUserDisplayNameAndUsernameIndex()
        
    ])
}
