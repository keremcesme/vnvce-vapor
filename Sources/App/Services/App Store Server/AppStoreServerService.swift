
import Vapor

extension Application {
    public var appStoreServer: AppStoreServer {
        .init(self)
    }
    
    public struct AppStoreServer {
        private let application: Application
        
        init(_ application: Application) {
            self.application = application
        }
        
        private struct ConfigurationKey: StorageKey {
            typealias Value = AppStoreServerConfiguration
        }
        
        public var configuration: AppStoreServerConfiguration? {
            get {
                self.application.storage[ConfigurationKey.self]
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
}

public struct AppStoreServerConfiguration {
    public let key: String
    
    init(key: String) {
        self.key = key
    }
}
