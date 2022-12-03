
import Fluent
import Vapor
import VNVCECore

extension User {
    func convertToPrivateV1(on db: Database) async throws -> PrivateUserV1 {
        let username = try await getUsername(on: db)
        let phoneNumber = try await getPhoneNumber(on: db)
        
        guard
            let createdAt = createdAt?.timeIntervalSince1970,
            let updatedAt = modifiedAt?.timeIntervalSince1970
        else {
            throw Abort(.notFound)
        }
        
        return .init(
            id: try self.requireID(),
            username: username,
            phoneNumber: phoneNumber,
            displayName: displayName,
            biography: biography,
            createdAt: createdAt,
            updatedAt: updatedAt)
    }
}

extension Array where Element: User {
    func convertToPublicV1(on db: Database) async throws -> [PrivateUserV1] {
        var privateUsers = [PrivateUserV1]()
        for user in self {
            let privateUser = try await user.convertToPrivateV1(on: db)
            privateUsers.append(privateUser)
        }
        return privateUsers
    }
}
