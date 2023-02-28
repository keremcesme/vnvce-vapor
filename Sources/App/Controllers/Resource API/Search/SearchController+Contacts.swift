
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
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
//        let userPhoneNumber = try await user.$phoneNumber.get(on: req.db)?.phoneNumber
        
        var phoneNumbers = try req.content.decode(SearchFromContactsPayload.V1.self).phoneNumbers
        
//        if let index = phoneNumbers.firstIndex(where: { $0 == userPhoneNumber}) {
//            phoneNumbers.remove(at: index)
//        }
        
        let users = try await User.query(on: req.db)
            .with(\.$username)
            .join(child: \.$phoneNumber)
            .filter(\.$id != userID)
            .filter(PhoneNumber.self, \PhoneNumber.$phoneNumber ~~ phoneNumbers)
            .all()
        
        let publicUsers: [User.V1.Public] = try await users
            .checkBlockStatus(userID, on: req.db)
            .convertToPublicV1(on: req.db)
        
        return publicUsers
    }
}
