////
////  File.swift
////
////
////  Created by Kerem Cesme on 21.08.2022.
////
//
//import Fluent
//import Vapor
//
//// MARK: AuthController V1 - Create Account - Account - Helper -
//extension AuthController.V1.CreateAccount {
//    func createUser(
//        username: String,
//        otp: VerifySMSPayload.V1,
//        _ req: Request
//    ) async throws -> AccountResult.V1 {
//        let clientID = otp.clientID
//        let phoneNumber = otp.phoneNumber
//
//        let user = User()
//
//        let result: AccountResult.V1 = try await req.db.transaction({
//            try await user.create(on: $0)
//            let userID = try user.requireID()
//
//            try await self.createPhoneNumberAndUsername(
//                phoneNumber: phoneNumber,
//                username: username,
//                userID: userID,
//                db: $0)
//
//            let tokens = try await self.createTokens(
//                userID: userID,
//                clientID: clientID,
//                db: $0)
//
//            let user = try await user.convertToPrivate($0)
//
//            return AccountResult.V1(user: user, tokens: tokens)
//        })
//        return result
//    }
//
//    private func createPhoneNumberAndUsername(
//        phoneNumber: String,
//        username: String,
//        userID: UUID,
//        db: Database
//    ) async throws {
//        let phoneNumber = PhoneNumber(phoneNumber: phoneNumber, user: userID)
//        let username = Username(username: username, user: userID)
//
//        try await phoneNumber.create(on: db)
//        try await username.create(on: db)
//
//        try await ReservedUsername.query(on: db)
//            .filter(\.$username == username.username)
//            .filter(\.$username, .contains(inverse: false, .anywhere), "asf")
//        //            .filter(\.$username, .custom("@@"), "sadf")
//            .delete(force: true)
//    }
//
//    private func createTokens(
//        userID: UUID,
//        clientID: UUID,
//        db: Database
//    ) async throws -> Tokens {
//        let refreshToken = RefreshToken.generate(
//            userID: userID,
//            clientID: clientID)
//
//        try await refreshToken.create(on: db)
//
//        let accessToken = AccessToken.generate(
//            userID: userID,
//            refreshTokenID: try refreshToken.requireID(),
//            clientID: clientID)
//
//        try await accessToken.create(on: db)
//
//        return Tokens(accessToken: accessToken.token, refreshToken: refreshToken.token)
//    }
//
//}
