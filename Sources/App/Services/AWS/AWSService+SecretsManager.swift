
import Vapor
import SotoSecretsManager

extension Application.AWS {
    public var secrets: AWSConfiguration.Secrets {
        .init(self.configuration)
    }
}

extension AWSConfiguration {
    public struct Secrets {
        public let secretsManager: SecretsManager?
            
        public init(_ config: AWSConfiguration?){
            if let config {
                self.secretsManager = .init(client: config.client, region: .eucentral1)
            } else {
                self.secretsManager = nil
            }
        }
        
        public func getSecretString(_ key: String) async throws -> String {
            guard let secretsManager else {
                throw Abort(.notFound)
            }
            
            let response = try await secretsManager.getSecretValue(.init(secretId: key))
            
            guard let value = response.secretString else {
                return ""
            }
            
            return value
        }
        
        public func getSecretData(_ key: String) async throws -> Data {
            guard let secretsManager else {
                throw Abort(.notFound)
            }
            
            let response = try await secretsManager.getSecretValue(.init(secretId: key))
            
            guard let value = response.secretString, let data = value.data(using: .utf8) else {
                return Data()
            }
            
            return data
        }
        
        public func getSecret<T: Decodable>(_ key: String, to: T.Type) async throws -> T {
            guard let secretsManager else {
                throw Abort(.notFound)
            }
            
            let response = try await secretsManager.getSecretValue(.init(secretId: key))
            
            guard let value = response.secretString, let data = value.data(using: .utf8) else {
                throw Abort(.notFound)
            }
            
            return try JSONDecoder().decode(to.self, from: data)
        }
        
        public func getSecretJSON(_ key: String) async throws -> [String: Any] {
            guard let secretsManager else {
                throw Abort(.notFound)
            }
            
            let response = try await secretsManager.getSecretValue(.init(secretId: key))
            
            guard let value = response.secretString, let data = value.data(using: .utf8) else {
                throw Abort(.notFound)
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String : Any]
        }
        
    }
}
