
import Vapor
import Fluent
import VNVCECore

extension MomentController {
    
    public func uploadHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await uploadV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func uploadV1(_ req: Request) async throws -> HTTPStatus {
        let userID = try req.auth.require(User.self).requireID()
        let payload = try req.content.decode(UploadMomentPayload.V1.self)
        
        let moment = Moment(id: payload.id, ownerID: userID, audience: payload.audience, location: payload.location?.convert)
        
        try await req.db.transaction {
            try await moment.create(on: $0)
            let momentID = try moment.requireID()
            let media = payload.media
            let mediaDetails = MomentMediaDetail(momentID: momentID, mediaType: media.mediaType, url: media.url, thumbnailURL: media.thumbnailURL)
            try await mediaDetails.create(on: $0)
        }
        
        return .ok
    }
    
}
