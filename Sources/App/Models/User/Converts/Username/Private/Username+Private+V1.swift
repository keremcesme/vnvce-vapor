
import Fluent
import Vapor
import VNVCECore

extension User {
    func getPrivateUsernameV1(on db: Database) async throws -> Username.V1 {
        guard let result = try await self.$username.get(on: db),
              let modifiedAt = result.modifiedAt?.timeIntervalSince1970 else {
            throw Abort(.notFound)
        }
        
        return .init(username: result.username, modifiedAt: modifiedAt)
    }
}
