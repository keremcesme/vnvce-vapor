
import Vapor
import Fluent
import VNVCECore

// MARK: SearchController - Version Routes -
struct SearchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("search")
        
        api.post("user", use: searchUserHandler)
    }
    
    func searchUserHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await searchUserV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func searchUserV1(_ req: Request) async throws -> PaginationResponse<User.V1.Public> {
        let userID = try req.auth.require(User.self).requireID()
        
        let searchText = try req.content.decode(String.self)
        
        let result = try await User.query(on: req.db)
            .with(\.$username)
            .join(child: \.$username)
            .group(.or) { query in
                query
                    .filter(.custom("display_name @@ to_tsquery('\(searchText)')"))
                    .filter(Username.self, \Username.$username, .custom("ilike"), "%\(searchText)%")
            }
            .paginate(for: req)
        
        let publicUsers: [User.V1.Public] = try await result.items
            .checkBlockStatus(userID, on: req.db)
            .convertToPublicV1(on: req.db)
        
        return .init(items: publicUsers, metadata: result.metadata)
    }
    
}

//    .filter(\.$displayName, .custom("ilike"), "%\(queryTerm)%")
//    .filter(Username.self, \Username.$username, .custom("ilike"), "%\(queryTerm)%")
