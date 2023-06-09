//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Fluent
import Vapor

// MARK: MeController V1 - Edit - Methods -
//extension MeController.V1.Edit {
//    
//    // MARK: Profile Picture
//    func editProfilePictureHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        
//        let payload = try req.content.decode(EditProfilePicturePayload.V1.self)
//        let url = payload.url
//        let name = payload.name
//        let alignment = payload.alignment
//        
//        let userID = try user.requireID()
//        let profilePicture = ProfilePicture(userID: userID, url: url, name: name)
//        try await req.db.transaction({
//            try await user.$profilePicture.get(on: $0)?.delete(on: $0)
//            try await user.$profilePicture.create(profilePicture, on: $0)
//        })
//        return .ok
//    }
//    
//    func deleteProfilePictureHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        try await user.$profilePicture.get(on: req.db)?.delete(on: req.db)
//        return .ok
//    }
//    
//    // MARK: Display Name
//    func editDisplayNameHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        let displayName = try req.content.decode(String.self)
//        user.displayName = displayName
//        try await user.update(on: req.db)
//        return .ok
//    }
//    
//    func deleteDisplayNameHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        user.displayName = nil
//        try await user.update(on: req.db)
//        return .ok
//    }
//    
//    // MARK: Biography
//    func editBiographyHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        let biography = try req.content.decode(String.self)
//        user.biography = biography
//        try await user.update(on: req.db)
//        return .ok
//    }
//    
//    func deleteBiographyHandler(_ req: Request) async throws -> HTTPStatus {
//        let user = try req.auth.require(User.self)
//        user.biography = nil
//        try await user.update(on: req.db)
//        return .ok
//    }
//    
//}
