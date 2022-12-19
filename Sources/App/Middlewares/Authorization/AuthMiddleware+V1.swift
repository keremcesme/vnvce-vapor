
import Vapor
import Fluent
import JWT

extension AuthMiddleware {
    public func authorizationV1(_ req: Request) async throws {
        guard let accessToken = req.headers.bearerAuthorization?.token,
              let authID = req.headers.authID,
              let clientID = req.headers.clientID,
              let clientOS = req.headers.clientOS
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        let redis = req.authService.redis.v1
        let jwtService = req.authService.jwt.v1
        
        /// [STEP 1]
        /// Verifying `Access Token` JWT.
        ///
        guard let decodedJWT = jwtService.validate(accessToken, as: JWT.AccessToken.V1.self) else {
            throw Abort(.forbidden)
        }
        
        guard decodedJWT.isVerified else {
            throw Abort(.unauthorized)
        }
        
        let jwtPayload = decodedJWT.payload
        
        let userID = jwtPayload.userID
        let atID = jwtPayload.id()
        let rtID = jwtPayload.refreshTokenID
        
        /// [STEP 2]
        /// Verifying `Access Token` from Redis database.
        guard let at = try await redis.getAccessTokenWithTTL(atID) else {
            ///
            /// The `Access Token` has expired or removed manually.
            ///
            throw Abort(.unauthorized)
        }
        
        guard at.payload.is_active else {
            ///
            /// [ REUSE DETECTED ][1]
            /// The `Access Token` has been revoked. But it was tried to be used again.
            ///
            throw Abort(.forbidden)
        }
        
        /// [STEP 3]
        /// Verifying `Refresh Token` from Redis database.
        guard let rt = await redis.getRefreshTokenWithTTL(rtID)
        else {
            ///
            /// [ REVOKE ][1]
            /// The `Access Token` will be revoked because (possible causes):
            ///     1 - The `Refresh Token` could not be found in the Redis database.
            ///     2 - The `Refresh Token` has expired.
            ///
            await redis.revokeAccessToken(atID, at)
            throw Abort(.unauthorized)
        }
        
        guard rt.payload.is_active else {
            ///
            /// [ REVOKE ][2]
            /// The `Access Token` will be revoked because the
            /// `Refresh Token` has been revoked.
            ///
            await redis.revokeAccessToken(atID, at)
            throw Abort(.forbidden)
        }
        
        guard rt.payload.inactivity_exp > Int(Date().timeIntervalSince1970) else {
            ///
            /// [ REVOKE ][3]
            /// The `Access Token` will be revoked because the
            /// `Refresh Token` inactivity time has expired.
            ///
            await redis.revokeAccessToken(atID, at)
            throw Abort(.unauthorized)
        }
        
        /// [STEP 4]
        /// Verifying `Auth` from Redis database.
        guard let auth = await redis.getAuth(authID),
                  auth.client_id == clientID,
                  auth.client_os == clientOS,
                  auth.user_id == userID,
                  auth.refresh_token_ids.contains(rtID),
                  auth.is_verified
        else {
            ///
            /// [ REVOKE ][4]
            /// `Access Token` and `Refresh Token` will be revoked because (possible causes):
            ///     1 -  The `Auth` could not be found in the Redis database.
            ///     2 -  The `Auth` has expired.
            ///     3 - `ClientID`, `ClientOS` or `UserID` did not match.
            ///     4 - `Refresh Token` not found in Auth.
            ///     5 - `Auth Code` (code_challenge) is not verified.
            ///
            await redis.revokeAccessToken(atID, at)
            await redis.revokeRefreshToken(rtID, rt)
            throw Abort(.forbidden)
        }
        
        /// [STEP 5]
        /// Verifying `User` from Redis database.
        guard let usr = await redis.getUser(userID),
                  usr.auth_token_ids.contains(authID)
        else {
            ///
            /// [ REVOKE / DELETE ][1]
            /// `Access Token`, all `Refresh Token`s and `Auth` will be deleted because (possible causes):
            ///     1 -  The `User` could not be found in the Redis database.
            ///     2 - `Auth ID` not found in User.
            ///
            await redis.revokeAccessToken(atID, at)
            await redis.deleteRefreshToken(rtID)
            await redis.deleteAllRefreshTokens(auth)
            await redis.deleteAuth(authID)
            throw Abort(.forbidden)
        }
        
        /// [STEP 6]
        /// Everything looks right. Retrieving `User` from source database (PSQL).
        guard let user = try await User.find(userID.uuid(), on: req.db) else {
            ///
            /// [ DELETE ][2]
            /// `User`, `Access Token`, all `Refresh Token`s and `Auth` will be deleted because:
            ///     1 - There is no such user.
            ///
            await redis.revokeAccessToken(atID)
            await redis.deleteRefreshToken(rtID)
            await redis.deleteAllRefreshTokens(auth)
            await redis.deleteAuth(authID)
            await redis.deleteAllAuths(usr)
            await redis.deleteUser(userID)
            throw Abort(.forbidden)
        }

        /// [STEP 7][FINAL]
        /// Everything is verified, the user is authorized.
        req.auth.login(user)
    }
}
