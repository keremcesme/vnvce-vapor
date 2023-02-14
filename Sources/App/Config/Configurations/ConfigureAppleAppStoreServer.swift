
import Vapor
import JWT

extension Application {
    private struct AppStoreServerCredentialsModel: Decodable {
        static let schema = "APPLE_IAP_CREDENTIALS"
        
        let key: String
        
        enum CodingKeys: String, CodingKey {
            case key = "KEY"
        }
    }
    
    func configureAppStoreServer() async throws {
        self.logger.notice("[ 6/9 ] Configuring App Store Server")
        let credentials = try await self.aws.secrets.getSecret(AppStoreServerCredentialsModel.schema, to: AppStoreServerCredentialsModel.self)
        
        let signer = try JWTSigner.es256(key: .private(pem: credentials.key.convertToKey))
        
        self.jwt.signers.use(signer, kid: .appStore, isDefault: false)
        
        self.appStoreServer.configuration = .init(key: credentials.key)
        
        self.logger.notice("✅ App Store Server Configured")
    }
}
