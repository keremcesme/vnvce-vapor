
import Vapor
import Fluent

struct MomentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("moment")
        
        api.get("fetch_friends_moments", use: fetchFriendsMomentsHandler)
        
        api.get("request_id", use: requestIdHandler)
        api.post("upload", use: uploadHandler)
        
        api.delete("delete", use: deleteHandler)
    }
}
