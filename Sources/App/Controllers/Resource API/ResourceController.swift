
import Vapor

public struct ResourceController: RouteCollection {
    
    public func boot(routes: RoutesBuilder) throws {
        let authMiddleware = AuthMiddleware()
        let guardMiddleware = User.guardMiddleware()
        
        let api = routes.grouped("resource")
            .grouped(authMiddleware)
            .grouped(guardMiddleware)
        
        let meController = MeController()
        let searchController = SearchController()
        
        try api.register(collection: meController)
        try api.register(collection: searchController)
        
    }
}
