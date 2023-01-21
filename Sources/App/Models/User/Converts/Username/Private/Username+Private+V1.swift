
import Fluent
import Vapor
import VNVCECore

extension User {
    func getPrivateUsernameV1(on db: Database) async throws -> Username.V1 {
        if let username = self.username,
           let modifiedAt = username.modifiedAt?.timeIntervalSince1970 {
            return .init(username: username.username, modifiedAt: modifiedAt)
        } else {
            try await self.$username.load(on: db)
            if let username = self.username,
               let modifiedAt = username.modifiedAt?.timeIntervalSince1970 {
                return .init(username: username.username, modifiedAt: modifiedAt)
            } else if let username = try await self.$username.get(on: db), let modifiedAt = username.modifiedAt?.timeIntervalSince1970 {
                return .init(username: username.username, modifiedAt: modifiedAt)
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
