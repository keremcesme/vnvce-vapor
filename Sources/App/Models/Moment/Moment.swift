
import Fluent
import Vapor
import FluentPostGIS
import VNVCECore

final class Moment: Model, Content {
    static let schema = "moments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: User
    
    @OptionalChild(for: \.$moment)
    var media: MomentMediaDetail?
    
    @OptionalField(key: "message")
    var message: String?
    
    @Enum(key: "audience")
    var audience: MomentAudience
    
    @OptionalField(key: "location")
    var location: GeometricPoint2D?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init(){}
    
    init(
        id: UUID,
        ownerID: User.IDValue,
        message: String?,
        audience: MomentAudience,
        location: GeometricPoint2D? = nil
    ){
        self.id = id
        self.$owner.id = ownerID
        self.message = message
        self.audience = audience
        self.location = location
    }
}

extension MomentLocation {
    var convert: GeometricPoint2D {
        return .init(x: self.latitude, y: self.longitude)
    }
}
