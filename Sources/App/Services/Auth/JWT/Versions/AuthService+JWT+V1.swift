
import Vapor
import JWT
import JWTDecode
import VNVCECore

extension AuthService.JWT {
    public struct V1 {
        public let app: Application
        
        private let decoder = JSONDecoder()
        
        init(_ app: Application) {
            self.app = app
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
    }
}

public extension AuthService.JWT.V1 {
    typealias AccessToken = JWT.AccessToken.V1
    typealias RefreshToken = JWT.RefreshToken.V1
    typealias AuthToken = JWT.AuthToken.V1
    typealias OTPToken = JWT.OTP.V1
    /// This method generates a `Refresh Token` and an `Access Token`.
    /// This method is only used for `login`, `sign up` operations.
    /// As an exception, it can be used after the RT has expired
    /// and the `PKCE Flow` has been successfully completed.
    func generateTokens(_ userID: String, _ authID: String) throws -> JWT.Tokens.V1 {
        let refreshToken = try generateRefreshToken(userID, authID)
        let accessToken = try generateAccessToken(userID, refreshToken.tokenID)
        return .init(refreshToken, accessToken)
    }
    
    /// An `Access Token` will be generated.
    func generateAccessToken(_ userID: String, _ refreshTokenID: String ) throws -> JWT.Token.V1 {
        let accessTokenID = UUID().uuidString
        let payload = AccessToken(userID, accessTokenID, refreshTokenID)
        let accessToken = try payload.sign(self.app)
        return .init(accessToken, accessTokenID)
    }
    
    /// An `Refresh Token` will be generated.
    func generateRefreshToken(_ userID: String, _ authID: String) throws -> JWT.Token.V1 {
        let refreshTokenID = UUID().uuidString
        let payload = RefreshToken(userID, refreshTokenID, authID)
        let refreshToken = try payload.sign(self.app)
        return .init(refreshToken, refreshTokenID)
    }
    
    /// An `Auth Token` will be generated.
    func generateAuthToken(_ userID: String, _ clientID: String, _ clientOS: ClientOS) throws -> JWT.Token.V1 {
        let authID = UUID().uuidString
        let payload = AuthToken(userID, clientID, clientOS, authID)
        let authToken = try payload.sign(self.app)
        return .init(authToken, authID)
    }
    
    /// An `OTP Token` will be generated.
    func generateOTPToken(_ userID: String? = nil, _ clientID: String, _ clientOS: ClientOS) throws -> JWT.Token.V1 {
        let otpID = UUID().uuidString
        let payload = OTPToken(userID, clientID, clientOS, otpID)
        let otpToken = try payload.sign(self.app)
        return .init(otpToken, otpID)
    }
    
    typealias ValidationResult<P: JWTSignable> = JWT.ValidationResult.V1<P>
    func validate<P: JWTSignable>(_ token: String, as payload: P.Type) -> ValidationResult<P>? {
        
        if let verifiedPayload = try? self.app.jwt.signers.verify(token, as: payload) {
            return .init(isVerified: true, payload: verifiedPayload)
        } else if let unverifiedPayload = try? self.app.jwt.signers.decode(token, as: payload) {
            return .init(isVerified: false, payload: unverifiedPayload)
        } else {
            return nil
        }
    }
}
