
import Fluent
import Vapor

extension User {
    func getPrivateProfilePictureV1(on db: Database) async throws -> ProfilePicture.V1 {
        if let profilePicture = self.profilePicture {
            return .init(url: profilePicture.url, name: profilePicture.name)
        } else {
            try await self.$profilePicture.load(on: db)
            if let profilePicture = self.profilePicture {
                return .init(url: profilePicture.url, name: profilePicture.name)
            } else if let profilePicture = try await self.$profilePicture.get(on: db) {
                return .init(url: profilePicture.url, name: profilePicture.name)
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
