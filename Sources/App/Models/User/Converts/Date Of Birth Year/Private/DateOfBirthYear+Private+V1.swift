
import Fluent
import Vapor

extension User {
    func getPrivateDateOfBirthYear(on db: Database) async throws -> Int {
        if let year = self.dateOfBirth?.year {
            return year
        } else {
            try await self.$dateOfBirth.load(on: db)
            if let year = self.dateOfBirth?.year {
                return year
            } else if let year = try await self.$dateOfBirth.get(on: db)?.year {
                return year
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
