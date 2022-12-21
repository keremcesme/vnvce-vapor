
import Vapor
import Fluent
import VNVCECore

final class Session: Model, Content {
    static let schema = "sessions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "auth_id")
    var authID: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "client_id")
    var clientID: String
    
    @Enum(key: "client_os")
    var clientOS: ClientOS
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        authID: String,
        userID: User.IDValue,
        clientID: String,
        clientOS: ClientOS
    ) {
        self.authID = authID
        self.$user.id = userID
        self.clientID = clientID
        self.clientOS = clientOS
    }
}
