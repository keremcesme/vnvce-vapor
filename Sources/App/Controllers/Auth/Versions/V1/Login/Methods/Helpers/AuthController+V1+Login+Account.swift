//
//  File.swift
//  
//
//  Created by Kerem Cesme on 24.08.2022.
//

import Fluent
import Vapor

// MARK: AuthController V1 - Login - Account - Helper -
extension AuthController.V1.Login {
    func login(
        otp: VerifySMSPayload.V1,
        _ req: Request
    ) async throws -> AccountResult.V1 {
        
        guard let user = try await User.query(on: req.db)
            .join(child: \.$phoneNumber)
            .filter(PhoneNumber.self, \.$phoneNumber == otp.phoneNumber)
            .first()
        else {
            throw Abort(.notFound, reason: "User not found.")
        }
        let userID = try user.requireID()
        
        let tokens = try await generateTokens(userID: userID, clientID: otp.clientID, req)
        
        let userConverted = try await user.convertToPrivate(req.db)
        
        return AccountResult.V1(user: userConverted, tokens: tokens)
    }
    
    private func generateTokens(userID: UUID, clientID: UUID, _ req: Request) async throws -> Tokens {
        
        let tokens: Tokens = try await req.db.transaction({ transaction -> Tokens in
            try await RefreshToken.query(on: req.db)
                .filter(\.$user.$id == userID)
                .delete()
            let refreshTokenNew = RefreshToken.generate(
                userID: userID,
                clientID: clientID)
            try await refreshTokenNew.create(on: transaction)
            let accessToken = AccessToken.generate(
                userID: userID,
                refreshTokenID: try refreshTokenNew.requireID(),
                clientID: clientID)
            try await accessToken.create(on: transaction)
            return Tokens(accessToken: accessToken.token, refreshToken: refreshTokenNew.token)
        })
        
        return tokens
    }
}
