
import Fluent
import Vapor

extension User {
    func getPublicUsernameV1(on db: Database) async throws -> String {
        if let username = self.username?.username {
            return username
        } else {
            try await self.$username.load(on: db)
            if let username = self.username?.username {
                return username
            } else if let username = try await self.$username.get(on: db)?.username {
                return username
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
