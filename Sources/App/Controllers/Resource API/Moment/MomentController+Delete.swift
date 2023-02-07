
import Vapor
import Fluent
import VNVCECore

extension MomentController {
    public func deleteHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await deleteV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func deleteV1(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        let momentID = try req.query.decode(DeleteMomentParam.V1.self).momentID.uuid()
        
        try await Moment.query(on: req.db)
            .filter(\.$id == momentID)
            .filter(\.$owner.$id == userID)
            .delete()
        
        return .ok
    }
}
