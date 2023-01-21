
import Fluent
import Vapor

extension User {
    func getPrivatePhoneNumberV1(on db: Database) async throws -> String {
        guard let phoneNumber = try await self.$phoneNumber.get(on: db)?.phoneNumber else {
            throw Abort(.notFound)
        }
        
        return phoneNumber
    }
}
