
import Vapor

public struct ResourceController: RouteCollection {
    
    public func boot(routes: RoutesBuilder) throws {
        let versionMiddleware = VersionMiddleware()
        let api = routes.grouped("resource")
            .grouped(versionMiddleware)
            .grouped(AuthMiddleware())
            .grouped(User.guardMiddleware())
        
        let meController = MeController()
        
        try api.register(collection: meController)
        
    }
}
