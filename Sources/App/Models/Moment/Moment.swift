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
    
    @Enum(key: "media_type")
    var mediaType: MediaType
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "thumbnail_url")
    var thumbnailURL: String?
    
    @Field(key: "sensitive_content")
    var sensitiveContent: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        ownerID: User.IDValue,
        mediaType: MediaType,
        name: String,
        url: String,
        thumbnailURL: String? = nil,
        sensitiveContent: Bool = false
    ){
        self.$owner.id = ownerID
        self.mediaType = mediaType
        self.name = name
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.sensitiveContent = sensitiveContent
    }
    
    struct V1: Content {
        let id: UUID
        let ownerID: UUID
        let name: String
        let url: String
        let sensitiveContent: Bool
        let createdAt: TimeInterval
    }
}

extension Moment {
    func convertMoment() throws -> Moment.V1 {
        guard let createdAt = self.createdAt else {
            throw NSError(domain: "", code: 1)
        }
        
        let timeInterval = createdAt.timeIntervalSince1970
        let momentID = try self.requireID()
        
        let moment = Moment.V1(
            id: momentID,
            ownerID: self.$owner.id,
            name: self.name,
            url: self.url,
            sensitiveContent: self.sensitiveContent,
            createdAt: timeInterval)
        return moment
    }
//    func testConvert() -> Moment.V1 {
//        let date = self.createdAt!
//        let calendar = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let hour = calendar.hour!
//        let minute = calendar.minute!
//
//        return Moment.V1(id: try! self.requireID(), hour: hour, minute: minute)
//    }
}

extension Array where Element: Moment {
    
    func convertMoments() throws -> [Moment.V1] {
        var moments = [Moment.V1]()
        for m in self {
            let moment = try m.convertMoment()
            moments.append(moment)
        }
        return moments
    }
    
//    func testConverts() -> [Moment.V1] {
//        var moments = [Moment.V1]()
//        for moment in self {
//            let result = moment.testConvert()
//            moments.append(result)
//        }
//        return moments
//    }
}

extension Array where Element == Moment.V1 {
//    func sortAndGroup() -> [[Moment.V1]] {
//
//        let result: [[Moment.V1]] = Dictionary(grouping: self, by: { $0.day })
//            .sorted(by: { $0.key > $1.key})
//            .map { $0.value}
//
//        return result
//    }
}

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
