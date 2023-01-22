
import Fluent
import Vapor

extension User {
    func getPrivateNotificationTokenV1(on db: Database) async throws -> String? {
        return try await self.$notificationToken.get(on: db)?.token
    }
}
