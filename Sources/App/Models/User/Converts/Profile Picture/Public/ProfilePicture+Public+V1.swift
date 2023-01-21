
import Fluent
import Vapor

extension User {
    func getPublicProfilePictureV1(on db: Database) async throws -> String? {
        let url = try await self.$profilePicture.get(on: db)?.url
        return url
    }
}
