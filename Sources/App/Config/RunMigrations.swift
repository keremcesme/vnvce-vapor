//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor

func runMigrations(_ app: Application) {
    app.migrations.add([
        
        // ENUMS - DATA TYPEs
        CreateProfilePictureAlignmentType(),
        CreateCoPostApprovalStatus(),
        CreateMediaType(),
        CreatePostType(),
        
        // AUTHENTICATION
        CreateSMSVerificationAttempt(),
        
        // USERNAME
        CreateReservedUsername(),
        
        // USER
        CreateUser(),
        CreateProfilePicture(),
        CreatePhoneNumber(),
        CreateUsername(),
        
        // AUTH TOKENS
        CreateRefreshToken(),
        CreateAccessToken(),
        
        // RELATIONSHIP
        CreateFriendship(),
        CreateFriendRequest(),
        CreateBlock(),
        
        // POST
        CreatePost(),
        
        // EXTENSIONS
        CreatePG_TRGMExtension(),
        CreateUserDisplayNameAndUsernameIndex()
        
    ])
}
