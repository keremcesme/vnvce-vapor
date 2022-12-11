//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor
import FluentPostGIS
import Fluent

extension Application {
    func configureMigrations() async {
        self.logger.notice("[ 7/8 ] Configuring Migrations")
        
        
        
        let types: [Migration] = [
            CreateProfilePictureAlignmentType(),
            CreateMediaType(),
            CreateDeviceOS()
        ]
        
        let users: [Migration] = [
            CreateUser(),
            CreatePhoneNumber(),
            CreateUsername(),
            CreateProfilePicture(),
            CreateNotificationToken()
        ]
        
        let relationships: [Migration] = [
            CreateFriendship(),
            CreateFriendRequest(),
            CreateBlock()
        ]
        
        let extensions: [Migration] = [
            EnablePostGISMigration(),
            CreatePG_TRGMExtension(),
            CreateUserDisplayNameAndUsernameIndex()
        ]
        
        self.migrations.add(types)
        self.migrations.add(users)
        self.migrations.add(relationships)
        self.migrations.add(extensions)
        
        self.logger.notice("✅ Migrations Configured")
    }
}
