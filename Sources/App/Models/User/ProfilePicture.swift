
import Fluent
import Vapor

final class ProfilePicture: Model, Content, Authenticatable {
    static let schema = "profile_pictures"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "url")
    var url: String
    
    @Field(key: "name")
    var name: String
    
    init() {}
    
    init(
        userID: User.IDValue,
        url: String,
        name: String
    ) {
        self.$user.id = userID
        self.url = url
        self.name = name
    }
}

