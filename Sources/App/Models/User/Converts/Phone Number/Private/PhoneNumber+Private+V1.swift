
import Fluent
import Vapor

extension User {
    func getPrivatePhoneNumberV1(on db: Database) async throws -> String {
        if let phoneNumber = self.phoneNumber?.phoneNumber {
            return phoneNumber
        } else {
            try await self.$phoneNumber.load(on: db)
            if let phoneNumber = self.phoneNumber?.phoneNumber {
                return phoneNumber
            } else if let phoneNumber = try await self.$phoneNumber.get(on: db)?.phoneNumber {
                return phoneNumber
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
