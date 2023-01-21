
import Fluent
import Vapor

extension User {
    func getPublicProfilePictureV1(on db: Database) async throws -> String {
        if let url = self.profilePicture?.url {
            return url
        } else {
            try await self.$profilePicture.load(on: db)
            if let url = self.profilePicture?.url {
                return url
            } else if let url = try await self.$profilePicture.get(on: db)?.url {
                return url
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
