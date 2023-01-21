
import Fluent
import Vapor

extension User {
    func getPublicUsernameV1(on db: Database) async throws -> String {
        guard let username = try await self.$username.get(on: db)?.username else {
            throw Abort(.notFound)
        }
        return username
    }
}
