
import Fluent
import Vapor

final class Country: Model, Content {
    static let schema = "countries"
    
    @ID(key: .id)
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
    var numcode: String
    
    @Field(key: "phonecode")
    var phonecode: String
    
    @Children(for: \.$country)
    var phoneNumbers: [PhoneNumber]
    
    
    init() {}
}
