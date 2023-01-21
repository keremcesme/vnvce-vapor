
import Fluent
import Vapor
import VNVCECore

extension User {
    func convertToPrivateV1(on db: Database) async throws -> User.V1.Private {
        let userID = try self.requireID()
        let username = try await getPrivateUsernameV1(on: db)
        let profilePicture = try await getPrivateProfilePictureV1(on: db)
        let phoneNumber = try await getPrivatePhoneNumberV1(on: db)
        let dateOfBirthYear = try await getPrivateDateOfBirthYear(on: db)
        
        guard let createdAt = self.createdAt?.timeIntervalSince1970 else {
            throw Abort(.badRequest)
        }
        
        return .init(
            id: userID,
            username: username,
            phoneNumber: phoneNumber,
            displayName: displayName,
            profilePicture: profilePicture,
            dateOfBirthYear: dateOfBirthYear,
            createdAt: createdAt)
    }
}
