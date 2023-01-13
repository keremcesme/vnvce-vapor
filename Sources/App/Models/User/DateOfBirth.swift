
import Fluent
import Vapor
import VNVCECore

final class DateOfBirth: Model, Content {
    static let schema = "birth_dates"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "day")
    var day: Int
    
    @Enum(key: "month")
    var month: Month
    
    @Field(key: "year")
    var year: Int
    
    init(){}
    
    init(
        userID: User.IDValue,
        day: Int,
        month: Month,
        year: Int
    ) {
        self.$user.id = userID
        self.day = day
        self.month = month
        self.year = year
    }
}
