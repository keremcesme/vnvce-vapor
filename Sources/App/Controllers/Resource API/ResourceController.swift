
import Vapor

// MARK: ResourceController - RESROUCE API
// Here are all the routes for access resources.

public struct ResourceController: RouteCollection {
    
    // MARK: Resource: vnvce.com/api/resource/
    public func boot(routes: RoutesBuilder) throws {
        let authMiddleware = AuthMiddleware()
        let guardMiddleware = User.guardMiddleware()
        
        // Authorization
        let api = routes.grouped("resource")
            .grouped(authMiddleware)
            .grouped(guardMiddleware)
        
        // Routes
        let meController = MeController()
        let searchController = SearchController()
        
        try api.register(collection: meController)
        try api.register(collection: searchController)
    }
}
