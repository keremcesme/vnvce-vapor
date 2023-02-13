
import Vapor

public struct AppStoreServerController: RouteCollection {
    
    public func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("apple")
        
        api.post("notifications", use: notificationsHandler)
        
    }
    
    
}
