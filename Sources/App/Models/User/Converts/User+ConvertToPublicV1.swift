
import Fluent
import Vapor
import VNVCECore

extension User {
    func convertToPublicV1(on db: Database) async throws -> PublicUserV1 {
        let username = try await getUsername(on: db)
        
        return .init(
            id: try self.requireID(),
            username: username,
            displayName: displayName,
            biography: biography)
    }
}

extension Array where Element: User {
    func convertToPublicV1(on db: Database) async throws -> [PublicUserV1] {
        var publicUsers = [PublicUserV1]()
        for user in self {
            let publicUser = try await user.convertToPublicV1(on: db)
            publicUsers.append(publicUser)
        }
        return publicUsers
    }
}
