//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import Vapor
import FluentPostGIS
import VNVCECore

final class Moment: Model, Content {
    static let schema = "moments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: User
    
    @OptionalChild(for: \.$moment)
    var media: MomentMediaDetail?
    
//    @OptionalField(key: "location")
//    var location: GeometricPoint2D?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        id: UUID,
        ownerID: User.IDValue
//        location: GeometricPoint2D? = nil
    ){
        self.id = id
        self.$owner.id = ownerID
//        self.location = location
    }
    
//    struct V1: Content {
//        let id: UUID
//        let ownerID: UUID
//        let name: String
//        let url: String
//        let sensitiveContent: Bool
//        let createdAt: TimeInterval
//    }
}

//extension Moment {
//    func convertMoment() throws -> Moment.V1 {
//        guard let createdAt = self.createdAt else {
//            throw NSError(domain: "", code: 1)
//        }
//
//        let timeInterval = createdAt.timeIntervalSince1970
//        let momentID = try self.requireID()
//
//        let moment = Moment.V1(
//            id: momentID,
//            ownerID: self.$owner.id,
//            name: self.name,
//            url: self.url,
//            sensitiveContent: self.sensitiveContent,
//            createdAt: timeInterval)
//        return moment
//    }
//}
//
//extension Array where Element: Moment {
//
//    func convertMoments() throws -> [Moment.V1] {
//        var moments = [Moment.V1]()
//        for m in self {
//            let moment = try m.convertMoment()
//            moments.append(moment)
//        }
//        return moments
//    }
//}






//extension Array where Element == Moment.V1 {
//    func sortAndGroup() -> [[Moment.V1]] {
//
//        let result: [[Moment.V1]] = Dictionary(grouping: self, by: { $0.day })
//            .sorted(by: { $0.key > $1.key})
//            .map { $0.value}
//
//        return result
//    }
//}

//extension Moment {
//    func convertMoment(owner: User.Public, _ db: Database) async throws -> Moment.V1 {
//        guard let createdAt = self.createdAt?.timeIntervalSince1970 else {
//            throw NSError(domain: "", code: 1)
//        }
//
//        try await self.$media.load(on: db)
//
//        return Moment.V1(id: try self.requireID(), owner: owner, media: self.media!.convert(), createdAt: createdAt)
//    }
//}
//
//extension Array where Element: Moment {
//    func convertMoments(owner: User.Public, _ db: Database) async throws -> [Moment.V1] {
//        var moments = [Moment.V1]()
//        for moment in self {
//            let result = try await moment.convertMoment(owner: owner, db)
//            moments.append(result)
//        }
//        return moments
//    }
//}
