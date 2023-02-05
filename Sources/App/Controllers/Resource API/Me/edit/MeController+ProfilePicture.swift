
import Vapor
import Fluent
import VNVCECore

extension MeController {
    public func editProfilePictureHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await editProfilePictureV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func editProfilePictureV1(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        let payload = try req.content.decode(EditProfilePicturePayload.V1.self)
        
        if var profilePicture = try await user.$profilePicture.get(on: req.db) {
            profilePicture.name = payload.name
            profilePicture.url = payload.url
            
            try await profilePicture.update(on: req.db)
        } else {
            let userID = try user.requireID()
            let profilePicture = ProfilePicture(userID: userID, url: payload.url, name: payload.name)
            
            try await user.$profilePicture.create(profilePicture, on: req.db)
        }
        
        return .ok
    }
}
