
import Fluent
import Vapor

final class Country: Model, Content {
    static let schema = "countries"
    
    @ID(custom: "id")
    var id: Int?
    
    @Field(key: "iso")
    var iso: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "nicename")
    var nicename: String
    
    @Field(key: "iso3")
    var iso3: String
    
    @Field(key: "numcode")
    var numcode: Int
    
    @Field(key: "phonecode")
    var phonecode: Int
    
    @Children(for: \.$country)
    var phoneNumbers: [PhoneNumber]
    
    
    init() {}
}
