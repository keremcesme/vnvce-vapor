
import Fluent
import Vapor
import VNVCECore

extension User {
    func convertToPublicV1(on db: Database) async throws -> User.V1.Public {
        let userID = try self.requireID()
        let username = try await getPublicUsernameV1(on: db)
        let profilePicture = try await getPublicProfilePictureV1(on: db)
        
        return .init(
            id: userID,
            username: username,
            displayName: displayName,
            profilePictureURL: profilePicture)
    }
}

extension Array where Element: User {
    func convertToPublicV1(on db: Database) async throws -> [User.V1.Public] {
        var publicUsers = [User.V1.Public]()
        for user in self {
            let publicUser = try await user.convertToPublicV1(on: db)
            publicUsers.append(publicUser)
        }
        return publicUsers
    }
}
