//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import Vapor

final class Moment: Model, Content {
    static let schema = "moments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: User
    
    @Parent(key: "day_id")
    var day: MomentDay
    
    @OptionalChild(for: \.$moment)
    var media: MomentMedia?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        ownerID: User.IDValue,
        dayID: MomentDay.IDValue
    ){
        self.$owner.id = ownerID
        self.$day.id = dayID
    }
    
    struct V1: Content {
        let id: UUID
        let owner: User.Public
        let media: MomentMedia.V1
        let createdAt: TimeInterval
    }
}

extension Moment {
    func convertMoment(owner: User.Public, _ db: Database) async throws -> Moment.V1 {
        guard let createdAt = self.createdAt?.timeIntervalSince1970 else {
            throw NSError(domain: "", code: 1)
        }
        
        try await self.$media.load(on: db)
        
        return Moment.V1(id: try self.requireID(), owner: owner, media: self.media!.convert(), createdAt: createdAt)
    }
}

extension Array where Element: Moment {
    func convertMoments(owner: User.Public, _ db: Database) async throws -> [Moment.V1] {
        var moments = [Moment.V1]()
        for moment in self {
            let result = try await moment.convertMoment(owner: owner, db)
            moments.append(result)
        }
        return moments
    }
}
