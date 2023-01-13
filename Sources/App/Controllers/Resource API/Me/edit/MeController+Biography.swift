
import Vapor
import Fluent
import VNVCECore

extension MeController {
    public func editBiographyHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await editBiographyV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func editBiographyV1(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        let biography = try req.content.decode(EditBiographyPayload.V1.self).biography
        
        user.biography = biography
        
        try await user.update(on: req.db)
        
        return .ok
    }
}
