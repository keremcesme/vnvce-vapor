//
//  File.swift
//  
//
//  Created by Kerem Cesme on 22.08.2022.
//

import Fluent
import Vapor

extension TokenController.V1 {
    
    func generate(_ req: Request) async throws -> Response<TokenResponse.V1>{
        let payload = try req.content.decode(GenerateTokensPayload.V1.self)
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
            let error: TokenGenerateError.V1 = .notFound
            return Response(result: .failure(error), message: error.rawValue)
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
            let result = GeneratedTokens.V1(accessToken: accessToken.token)
            return Response(result: .success(result), message: result.message)
        }
        
        try await refreshToken.delete(on: req.db)
        guard refreshToken.clientID == clientID else {
            let error: TokenGenerateError.V1 = .clientIdNotMatch
            return Response(result: .failure(error), message: error.rawValue)
        }
        
        
        
        let tokens: GeneratedTokens.V1 = try await req.db.transaction({ transaction -> GeneratedTokens.V1 in
            let refreshTokenNew = RefreshToken.generate(
                userID: userID,
                clientID: clientID)
            try await refreshTokenNew.create(on: transaction)
            let accessToken = AccessToken.generate(
                userID: userID,
                refreshTokenID: try refreshTokenNew.requireID(),
                clientID: clientID)
            try await accessToken.create(on: transaction)
            return GeneratedTokens.V1(accessToken: accessToken.token, refreshToken: refreshTokenNew.token)
        })
        return Response(result: .success(tokens), message: tokens.message)
    }
}
