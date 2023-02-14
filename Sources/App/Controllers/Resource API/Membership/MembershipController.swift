
import Vapor
import Fluent

struct MembershipController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("membership")
        
        api.post("transaction", use: transactionHandler)
        
    }
}
