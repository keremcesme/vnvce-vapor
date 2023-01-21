
import Vapor
import Fluent
import VNVCECore

extension MeController {
    public func profileHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await profileV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func profileV1(_ req: Request) async throws -> User.V1.Private {
        return try await req.auth.require(User.self).convertToPrivateV1(on: req.db)
    }
}
