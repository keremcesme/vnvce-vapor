//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.11.2022.
//

import Vapor
import JWT

extension Application {
    
    private struct RSAKeysModel: Decodable {
        public static let schema = "JWT_RSA_KEYS"
        
        let publicKey: String
        let privateKey: String
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.publicKey = try container.decode(String.self, forKey: CodingKeys.publicKey).convertToKey
            self.privateKey = try container.decode(String.self, forKey: CodingKeys.privateKey).convertToKey
        }
        
        enum CodingKeys: String, CodingKey {
            case publicKey = "PUBLIC_KEY"
            case privateKey = "PRIVATE_KEY"
        }
    }
    
    public func configureJWT() async throws {
        self.logger.notice("[ 4/8 ] Configuring JWT")
        
        let keys = try await self.aws.secrets.getSecret(RSAKeysModel.schema, to: RSAKeysModel.self)
        
        let publicSigner = try JWTSigner.rs256(key: .public(pem: keys.publicKey.bytes))
        let privateSigner = try JWTSigner.rs256(key: .private(pem: keys.privateKey.bytes))
        
        self.jwt.signers.use(publicSigner, kid: .public, isDefault: true)
        self.jwt.signers.use(privateSigner, kid: .private)
        
        self.logger.notice("✅ JWT Configured")
    }
}
