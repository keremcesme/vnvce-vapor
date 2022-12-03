
import Fluent
import Vapor

final class PhoneNumber: Model, Content {
    static let schema = "phone_numbers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "modified_at", on: .update)
    var modifiedAt: Date?
    
    init() {}
    
    init(
        phoneNumber: String,
        user: User.IDValue
    ) {
        self.phoneNumber  = phoneNumber
        self.$user.id = user
    }
}

extension User {
    func getPhoneNumber(on db: Database) async throws -> String {
        if let phoneNumber = self.phoneNumber?.phoneNumber {
            return phoneNumber
        } else {
            try await self.$phoneNumber.load(on: db)
            if let phoneNumber = self.phoneNumber?.phoneNumber {
                return phoneNumber
            } else if let phoneNumber = try await self.$phoneNumber.get(on: db)?.phoneNumber {
                return phoneNumber
            } else {
                throw Abort(.notFound)
            }
        }
    }
}
