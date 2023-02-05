
import Vapor
import Fluent
import VNVCECore

extension SearchController {
    public func searchFromContactsHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await searchFromContactsV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func searchFromContactsV1(_ req: Request) async throws -> [User.V1.Public] {
        let userID = try req.auth.require(User.self).requireID()
        
        let phoneNumbers = try req.content.decode(SearchFromContactsPayload.V1.self).phoneNumbers
        
        let users = try await User.query(on: req.db)
            .with(\.$username)
//            .with(\.$profilePicture)
            .join(child: \.$phoneNumber)
            .filter(PhoneNumber.self, \PhoneNumber.$phoneNumber ~~ phoneNumbers)
            .all()
        
        let publicUsers: [User.V1.Public] = try await users
            .checkBlockStatus(userID, on: req.db)
            .convertToPublicV1(on: req.db)
        
        return publicUsers
    }
}
