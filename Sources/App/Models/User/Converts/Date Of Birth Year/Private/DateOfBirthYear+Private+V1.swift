
import Fluent
import Vapor

extension User {
    func getPrivateDateOfBirthYear(on db: Database) async throws -> Int {
        guard let year = try await self.$dateOfBirth.get(on: db)?.year else {
            throw Abort(.notFound)
        }
        return year
    }
}
