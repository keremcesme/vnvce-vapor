
import Fluent
import Vapor
import VNVCECore

extension Moment {
    func convertToPublicV1(on db: Database) async throws -> Moment.V1.Public {
        let id = try self.requireID()
        
        guard let media = try await self.$media.get(on: db) else {
            throw Abort(.notFound)
        }
        
        guard let createdAt = self.createdAt?.timeIntervalSince1970 else {
            throw Abort(.notFound)
        }
        
        return .init(
            id: id,
            message: self.message,
            mediaType: media.mediaType,
            url: media.url,
            thumbnailURL: media.thumbnailURL,
            sensitiveContent: media.sensitiveContent,
            createdAt: createdAt)
    }
}

extension Array where Element: Moment {
    func convertToPublicV1(on db: Database) async throws -> [Moment.V1.Public] {
        var publicMoments = [Moment.V1.Public]()
        for moment in self {
            let publicMoment = try await moment.convertToPublicV1(on: db)
            publicMoments.append(publicMoment)
        }
        return publicMoments
    }
}
