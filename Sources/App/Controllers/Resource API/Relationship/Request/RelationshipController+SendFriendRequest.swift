
import Vapor
import Fluent
import APNS
import APNSwift
import VNVCECore

extension RelationshipController {
    public func sendFriendRequestHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await sendFriendRequestV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func sendFriendRequestV1(_ req: Request) async throws -> VNVCECore.Relationship.V1 {
        let userID = try req.auth.require(User.self).requireID()
        let targetUserID = try req.query.decode(RelationshipParam.V1.self).userID.uuid()
        let relationshipPayload = try req.content.decode(VNVCECore.Relationship.V1.self)
        let relationship = try await checkRelationshipV1(userID: userID, targetUserID: targetUserID, req.db)
        
        guard relationshipPayload == relationship else {
            throw Abort(.badRequest)
        }
        
        let friendRequest = FriendRequest(user: userID, submittedUser: targetUserID)
        
        try await friendRequest.create(on: req.db)
        
        // Send Push Notification is here:
        
        let requestID = try friendRequest.requireID()
        
        return .friendRequestSubmitted(requestID: requestID)
    }
}
