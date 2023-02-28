
import Vapor
import Fluent

struct NotificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("notification")
        
        api.post("register-token", use: registerTokenHandler)
        
        
    }
}
