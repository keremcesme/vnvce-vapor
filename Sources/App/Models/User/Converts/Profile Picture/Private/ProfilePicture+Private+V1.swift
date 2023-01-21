
import Fluent
import Vapor

extension User {
    func getPrivateProfilePictureV1(on db: Database) async throws -> ProfilePicture.V1? {
        let profilePicture = try await self.$profilePicture.get(on: db)
            
        if let profilePicture {
            return .init(url: profilePicture.url, name: profilePicture.name)
        } else {
            return nil
        }
    }
}
