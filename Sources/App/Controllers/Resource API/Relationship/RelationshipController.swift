
import Fluent
import Vapor

struct RelationshipController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("relationship")
        
        api.get("fetch", use: relationshipHandler)
        
        let request = api.grouped("request")
        request.post("send", use: sendFriendRequestHandler)
        request.post("accept", use: acceptFriendRequestHandler)
        request.post("undo-or-reject", use: undoOrRejectFriendRequestHandler)
        
        api.post("remove-friend", use: removeFriendHandler)
        
        api.post("block-user", use: blockUserHandler)
        api.post("unblock-user", use: unblockUserHandler)
    }
}
