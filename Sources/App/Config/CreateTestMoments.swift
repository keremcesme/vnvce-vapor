
import Vapor
import Fluent

extension Application {
    public func createTestMoments() async throws {
//        let date = Date()
//
//        print(date.timeIntervalSince1970)
//        print(date.addingTimeInterval(-172800).timeIntervalSince1970)
        
        let users = try await User
            .query(on: self.db)
            .all()

        for user in users {
            let userID = try user.requireID()
            guard userID != "19e9db27-1118-4fd7-ac57-e5f04f4edc8c".convertUUID,
                  userID != "bb70681b-f55f-456b-adce-d5ca70e30f8c".convertUUID
            else {
                continue
            }

            let randomInt = Int.random(in: 1..<6)

            for _ in 1...randomInt {
                let moment = Moment(id: UUID(), ownerID: userID, message: nil, audience: .friendsOnly, location: nil)
                let id: UUID = try await self.db.transaction {
                    try await moment.create(on: $0)
                    let momentID = try moment.requireID()
                    let mediaDetails = MomentMediaDetail(momentID: momentID, mediaType: .image, url: "https://source.unsplash.com/random/1440x2160/?city", thumbnailURL: nil)
                    
                    try await mediaDetails.create(on: $0)
                    return momentID
                }
                
                let randomDate = TimeInterval.random(in: 1683212688.810196...1683385488.810196)
                print(Date(timeIntervalSince1970: randomDate))
                let m = try await Moment.find(id, on: self.db)!
                m.createdAt = Date(timeIntervalSince1970: randomDate)

                try await m.update(on: self.db)
            }
        }
    }
}
