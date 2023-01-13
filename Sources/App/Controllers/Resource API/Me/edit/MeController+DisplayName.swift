
import Vapor
import Fluent
import VNVCECore

extension MeController {
    public func editDisplayNameHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await editDisplayNameV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func editDisplayNameV1(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        
        let displayName = try req.content.decode(EditDisplayNamePayload.V1.self).displayName
        
        user.displayName = displayName
        
        try await user.update(on: req.db)
        
        return .ok
    }
}
