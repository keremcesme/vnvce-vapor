
import Vapor
import VNVCECore

extension AuthController {
    public func checkUsernameHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await checkUsernameV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func checkUsernameV1(_ req: Request) async throws -> HTTPStatus {
        let p = try req.query.decode(CheckUsernameParams.V1.self)
        let username = req.authService.reservedUsername.v1
        let availability =  try await username.checkUsername(p.username, on: req)
        
        switch availability {
        case .notUsed, .reservedBySameUser:
            return .ok
        default:
            return .notFound
        }
    }
    
}
