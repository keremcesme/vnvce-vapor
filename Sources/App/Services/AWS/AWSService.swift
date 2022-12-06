
import Vapor
import SotoSecretsManager
import SotoSNS

extension Application {
    public var aws: AWS {
        .init(self)
    }
    
    public struct AWS {
        let application: Application
        
        init(_ application: Application) {
            self.application = application
        }
        
        private struct ConfigurationKey: StorageKey {
            typealias Value = AWSConfiguration
        }
        
        public var configuration: AWSConfiguration? {
            get {
                self.application.storage[ConfigurationKey.self]
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
        
        func getSecret() async throws -> String {
            guard let config = configuration else {
                throw Abort(.notFound)
            }
            
            let secretsManager = config.secretsManager
            
            let value = try await secretsManager.getSecretValue(.init(secretId: "JWT_RSA_KEYS"))
            
            guard let secret = value.secretString else {
                return ""
            }
            
            return secret
        }
    }
}

public struct AWSConfiguration {
    public let client: AWSClient
    
    public let secretsManager: SecretsManager
    
    init(keyID: String, key: String) {
        self.client = .init(credentialProvider: .static(accessKeyId: keyID, secretAccessKey: key), httpClientProvider: .createNew)
        self.secretsManager = .init(client: client, region: .eucentral1)
    }
}
