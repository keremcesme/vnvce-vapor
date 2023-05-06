
import Vapor
import Fluent
import VNVCECore

extension MomentController {
    public func fetchFriendsMomentsHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await fetchFriendsMomentsV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func fetchFriendsMomentsV1(_ req: Request) async throws -> [UserWithMoments.V1] {
        let userID = try req.auth.require(User.self).requireID()
        
        let friends: [User.V1.Public] = try await {
            let friendships = try await Friendship.query(on: req.db)
                .group(.or) { query in
                    query
                        .filter(\.$user1.$id == userID)
                        .filter(\.$user2.$id == userID)
                }
                .all()
            
            let friendIDs: [User.IDValue] = {
                friendships.map { value in
                    if value.$user1.id == userID {
                        return value.$user2.id
                    } else {
                        return value.$user1.id
                    }
                }
            }()
            
            return try await User.query(on: req.db)
                .filter(\.$id ~~ friendIDs)
                .all()
                .convertToPublicV1(on: req.db)
        }()
        
        
        var userWithMoments: [UserWithMoments.V1] = []
        
        for friend in friends {
            let moments = try await Moment.query(on: req.db)
                .filter(\.$owner.$id == friend.id)
                .all()
                .convertToPublicV1(on: req.db)
            let userWithMoment: UserWithMoments.V1 = .init(owner: friend, moments: moments)
            userWithMoments.append(userWithMoment)
        }
        
        return userWithMoments
    }
}
