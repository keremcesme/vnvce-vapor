
import Vapor
import Fluent
import VNVCECore

final class User: Model, Content, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "display_name")
    var displayName: String?
    
    @OptionalField(key: "biography")
    var biography: String?
    
    @OptionalField(key: "profile_picture_url")
    var profilePictureURL: String?
    
    @OptionalChild(for: \.$user)
    var username: Username?
    
    @OptionalChild(for: \.$user)
    var phoneNumber: PhoneNumber?
    
    @OptionalChild(for: \.$user)
    var dateOfBirth: DateOfBirth?
    
//    @OptionalChild(for: \.$user)
//    var profilePicture: ProfilePicture?
    
    @OptionalChild(for: \.$user)
    var notificationToken: NotificationToken?
    
    @Children(for: \.$user)
    var sessions: [Session]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init() {}
    
    init(displayName: String? = nil, biography: String? = nil, profilePictureURL: String? = nil) {
        self.displayName = displayName
        self.biography = biography
        self.profilePictureURL = profilePictureURL
    }
}




// MARK: Private User
//extension User {
//
//    func convertToPrivate(_ req: Request) async throws -> User.Private {
//        try await self.$username.load(on: req.db)
//        try await self.$phoneNumber.load(on: req.db)
//        try await self.$profilePicture.load(on: req.db)
//
//        return User.Private(
//            id: try self.requireID(),
//            username: self.username!.username,
//            phoneNumber: self.phoneNumber!.phoneNumber,
//            displayName: self.displayName,
//            biography: self.biography,
//            profilePicture: self.profilePicture?.convert()
//        )
//    }
//
//    func convertToPrivate(_ db: Database) async throws -> User.Private {
//        try await self.$username.load(on: db)
//        try await self.$phoneNumber.load(on: db)
//        try await self.$profilePicture.load(on: db)
//
//        return User.Private(
//            id: try self.requireID(),
//            username: self.username!.username,
//            phoneNumber: self.phoneNumber!.phoneNumber,
//            displayName: self.displayName,
//            biography: self.biography,
//            profilePicture: self.profilePicture?.convert()
//        )
//    }
//}
//
//// MARK: Public User
//extension User {
//    func convertToPublic(_ req: Request) async throws -> User.Public {
//        try await self.$username.load(on: req.db)
//        try await self.$profilePicture.load(on: req.db)
//
//        return User.Public(
//            id: try self.requireID(),
//            username: self.username!.username,
//            displayName: self.displayName,
//            biography: self.biography,
//            profilePicture: self.profilePicture?.convert()
//        )
//    }
//
//    func convertToPublic(_ db: Database) async throws -> User.Public {
//        try await self.$username.load(on: db)
//        try await self.$profilePicture.load(on: db)
//
//        return User.Public(
//            id: try self.requireID(),
//            username: self.username!.username,
//            displayName: self.displayName,
//            biography: self.biography,
//            profilePicture: self.profilePicture?.convert()
//        )
//    }
//}
//
//extension Array where Element: User {
//    func convertToPublic(_ req: Request) async throws -> [User.Public] {
//        var users = [User.Public]()
//        for user in self {
//            let publicUser = try await user.convertToPublic(req)
//            users.append(publicUser)
//        }
//        return users
//    }
//}
//
extension Array where Element: User {
    func checkBlockStatus(_ userID: User.IDValue, on db: Database) async throws -> [User] {
        var users = [User]()
        for user in self {
            let id = try user.requireID()
            guard try await Block.query(on: db)
                .filter(\.$blockedUser.$id == userID)
                .filter(\.$user.$id == id)
                .first() == nil else {
                continue
            }
            users.append(user)
        }
        return users
    }
}
