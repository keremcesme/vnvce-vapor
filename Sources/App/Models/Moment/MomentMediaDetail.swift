
import Vapor
import Fluent
import VNVCECore

final class MomentMediaDetail: Model, Content {
    static let schema = "moment_media_details"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "moment_id")
    var moment: Moment
    
    @Enum(key: "media_type")
    var mediaType: MediaType
    
    @Field(key: "url")
    var url: String
    
    @OptionalField(key: "thumbnail_url")
    var thumbnailURL: String?
    
    @Field(key: "sensitive_content")
    var sensitiveContent: Bool
    
    init(){}
    
    init(
        momentID: Moment.IDValue,
        mediaType: MediaType,
        url: String,
        thumbnailURL: String? = nil,
        sensitiveContent: Bool = false
    ) {
        self.$moment.id = momentID
        self.mediaType = mediaType
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.sensitiveContent = sensitiveContent
    }
}
