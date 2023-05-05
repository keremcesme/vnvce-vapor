
import Fluent
import Vapor
import VNVCECore

extension Moment {
    func convertToPrivateV1(on db: Database) async throws -> Moment.V1.Private {
        let id = try self.requireID()
        
        let media: MomentMediaDetail = try await {
            if let media = self.media {
                return media
            } else {
                try await self.$media.load(on: db)
                guard let media = self.media else {
                    throw Abort(.notFound)
                }
                return media
            }
        }()
        
        guard let createdAt = self.createdAt?.timeIntervalSince1970 else {
            throw Abort(.notFound)
        }
        
        return .init(
            id: id,
            message: self.message,
            audience: self.audience,
            location: self.location.convert,
            mediaType: media.mediaType,
            url: media.url,
            thumbnailURL: media.thumbnailURL,
            sensitiveContent: media.sensitiveContent,
            createdAt: createdAt)
    }
}
