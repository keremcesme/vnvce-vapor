//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Vapor
import Fluent

extension TokenController {
    
    func accessTokenValidation(_ req: Request) async throws -> HTTPStatus {
        _ = try req.auth.require(User.self)
        return .ok
    }
    
    func generateNewTokens(_ req: Request) async throws -> Response<TokenResponse>{
        let payload = try req.content.decode(GenerateTokensPayload.self)
        let userIDString = payload.userID
        let refreshToken = payload.refreshToken
        let clientID = payload.clientID
        
        guard let user = try await User.find(userIDString, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let userID = try user.requireID()
        
        guard let refreshToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token == refreshToken)
            .first() else {
            return Response(message: "No Found Refresh Token in the database", code: .ok)
        }
        
        try await AccessToken.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
            .delete(on: req.db)
        
        
        guard refreshToken.expiresAt > Date() else {
            let accessToken = AccessToken.generate(
                userID: userID,
                refreshTokenID: refreshToken.id!,
                clientID: payload.clientID)
            
            try await accessToken.create(on: req.db)
            
            return Response(result: TokenResponse(accessToken: accessToken.token), message: "Acces Token is generated.", code: .ok)
        }
        
        try await refreshToken.delete(on: req.db)
        
        guard refreshToken.clientID == clientID else {
            return Response(message: "Client ID not match.", code: .ok)
        }
        
        let accessToken = AccessToken.generate(
            userID: userID,
            refreshTokenID: refreshToken.id!,
            clientID: clientID)
        
        let refreshTokenNew = RefreshToken.generate(
            userID: userID,
            clientID: clientID)
        
        try await req.db.transaction({ transaction in
            try await accessToken.create(on: transaction)
            try await refreshTokenNew.create(on: transaction)
        })
        
        return Response(
            result: TokenResponse(
                accessToken: accessToken.token,
                refreshToken: refreshTokenNew.token),
            message: "Access and Refresh Token is generated.",
            code: .ok)
    }
    
    
}
