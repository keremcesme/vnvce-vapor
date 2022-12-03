
import Vapor
import Fluent
import VNVCECore

typealias PublicUserV1 = VNVCECore.UserModel.V1.Public
typealias PrivateUserV1 = VNVCECore.UserModel.V1.Private

extension PublicUserV1: Content {}
extension PrivateUserV1: Content {}

extension PublicUserV1 {
    init(_ user: User, on db: Database) async throws {
        let username = try await user.getUsername(on: db)
        
        try self.init(
            id: user.requireID(),
            username: username,
            displayName: user.displayName,
            biography: user.biography)
    }
}

extension PrivateUserV1 {
    init(_ user: User, on db: Database) async throws {
        let username = try await user.getUsername(on: db)
        let phoneNumber = try await user.getPhoneNumber(on: db)
        
        guard
            let createdAt = user.createdAt,
            let updatedAt = user.modifiedAt
        else {
            throw Abort(.notFound)
        }
        
        try self.init(
            id: user.requireID(),
            username: username,
            phoneNumber: phoneNumber,
            displayName: user.displayName,
            biography: user.biography,
            createdAt: createdAt.timeIntervalSince1970,
            updatedAt: updatedAt.timeIntervalSince1970)
    }
}
