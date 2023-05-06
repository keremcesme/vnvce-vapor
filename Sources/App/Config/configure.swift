
import Vapor
import Fluent
import JWT

extension Application {
    public func configure() async throws {
        try await self.startConfigurations()
    }
}

extension Application {
    private func startConfigurations() async throws {
        self.configureServer()
        
        self.logger.notice("[ INFO ] Total Configurations: 9")
        
        try await self.configureAWS()
        try await self.configureDatabase()
        try await self.configureRedis()
        try await self.configureJWT()
        try await self.configureAppleAPN()
        try await self.configureAppStoreServer()
        
        try self.configureRoutes()
        
        try await self.configureMigrations()
        self.configureViews()

        
        
        
//        try app.configureAppleDeviceCheck()
        
        // MARK: Create Test
//        try await self.createTestUsers()
//        try await self.createTestMoments()
        
//        let userID = User.IDValue(uuidString: "bb70681b-f55f-456b-adce-d5ca70e30f8c")!
//
//        let friends: [User.V1.Public] = try await {
//            let friendships = try await Friendship.query(on: self.db)
//                .group(.or) { query in
//                    query
//                        .filter(\.$user1.$id == userID)
//                        .filter(\.$user2.$id == userID)
//                }
//                .all()
//
//            let friendIDs: [User.IDValue] = {
//                friendships.map { value in
//                    if value.$user1.id == userID {
//                        return value.$user2.id
//                    } else {
//                        return value.$user1.id
//                    }
//                }
//            }()
//
//            return try await User.query(on: self.db)
//                .with(\.$username)
//                .filter(\.$id ~~ friendIDs)
//                .all()
//                .convertToPublicV1(on: self.db)
//        }()
//
//        let names: [String] = {
//            friends.map { user in
//                return user.username
//            }
//        }()
//        print("Count: \(friends.count)")
//        print("Friends: \(names)")
        
        self.logger.notice("[ RESULT ] 🎉 All Configurations Success 🎉")
    }
}

