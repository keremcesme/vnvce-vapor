//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import Vapor

//final class MomentDay: Model, Content {
//    static let schema = "moment_days"
//
//    @ID(key: .id)
//    var id: UUID?
//
//    @Parent(key: "owner_id")
//    var owner: User
//
//    @Field(key: "day")
//    var day: Int
//
//    @Enum(key: Month.schema.fieldKey)
//    var month: Month
//
//    @Field(key: "year")
//    var year: Int
//
//    @Children(for: \.$day)
//    var moments: [Moment]
//
//    @Timestamp(key: "created_at", on: .create)
//    var createdAt: Date?
//
//    @Timestamp(key: "modified_at", on: .update)
//    var modifiedAt: Date?
//
//    init(){}
//
//    init(
//        ownerID: User.IDValue,
//        day: Int,
//        month: Month,
//        year: Int
//    ) {
//        self.$owner.id = ownerID
//        self.day = day
//        self.month = month
//        self.year = year
//    }
//
//    struct V1: Content {
//        let id: UUID
//        let owner: User.Public
//        let moments: [Moment.V1]
//        let day: Int
//        let month: Month
//        let year: Int
//        let createdAt: TimeInterval
//        let modifiedAt: TimeInterval
//    }
//
//}
//
//extension MomentDay {
//    func convert(owner: User.Public, _ db: Database) async throws -> MomentDay.V1 {
//        guard let createdAt = self.createdAt?.timeIntervalSince1970,
//              let modifiedAt = self.modifiedAt?.timeIntervalSince1970
//        else {
//            throw NSError(domain: "", code: 1)
//        }
//
//        let moments = try await self.moments.convertMoments(owner: owner, db)
//
//        return MomentDay.V1(id: try self.requireID(),
//                            owner: owner,
//                            moments: moments,
//                            day: self.day,
//                            month: self.month,
//                            year: self.year,
//                            createdAt: createdAt,
//                            modifiedAt: modifiedAt)
//
//    }
//}
//
//extension Array where Element: MomentDay {
//    func convertMomentDays(owner: User.Public, _ db: Database) async throws -> [MomentDay.V1] {
//        var momentDays = [MomentDay.V1]()
//
//        for day in self {
//            let result = try await day.convert(owner: owner, db)
//            momentDays.append(result)
//        }
//
//        return momentDays
//    }
//}
