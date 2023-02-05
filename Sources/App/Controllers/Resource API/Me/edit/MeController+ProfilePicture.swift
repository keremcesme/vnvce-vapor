
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
        
        let url = try req.content.decode(EditProfilePicturePayload.V1.self).url
        
        user.profilePictureURL = url
        
        try await user.update(on: req.db)
        
        return .ok
    }
}
