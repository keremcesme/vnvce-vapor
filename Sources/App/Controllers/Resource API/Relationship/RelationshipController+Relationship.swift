
import Vapor
import Fluent
import VNVCECore

extension RelationshipController {
    public func relationshipHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await relationshipV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func relationshipV1(_ req: Request) async throws -> VNVCECore.Relationship.V1 {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try req.query.decode(RelationshipParam.V1.self).userID.uuid()
        
        let relationship = try await checkRelationshipV1(
            userID: userID,
            targetUserID: targetUserID,
            req.db)
        
        return relationship
    }
    
    
    
}

