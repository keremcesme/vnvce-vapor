
import Vapor
import Fluent
import JWT
import VNVCECore

extension AuthService.ReservedUsername {
    public struct V1 {
        public let app: Application
        
        init(_ app: Application) {
            self.app = app
        }
    }
}

public extension AuthService.ReservedUsername.V1 {
    typealias Availability = UsernameAvailability.V1
    
    ///
    /// Headers:
    ///  1 - X-Client-ID
    ///  2 - X-Client-OS
    ///
    /// Params:
    ///  1 - Username
    func checkUsername(_ username: String, on req: Request) async throws -> Availability {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        
        let redis = req.authService.redis.v1
        
        if try await usernameQuery(username, on: req.db) != nil {
            return .used
        }
        
        guard let reservedUsername = await redis.getUsername(username) else {
            return .notUsed
        }
        
        guard reservedUsername.clientOS == clientOS,
              reservedUsername.clientID == clientID
        else {
            return .reserved
        }
        
        return .reservedBySameUser
    }
    
    func reserveUsername(_ username: String, on req: Request) async throws {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        
        let redis = req.authService.redis.v1
        
        await redis.addUsername(
            username: username,
            clientID: clientID,
            clientOS: clientOS)
    }
    
    func verifyUsername(_ username: String, on req: Request) async throws {
        guard let clientID = req.headers.clientID else {
            throw Abort(.badRequest, reason: "The `X-Client-ID` header is missing.")
        }
        guard let clientOS = req.headers.clientOS else {
            throw Abort(.badRequest, reason: "The `X-Client-OS` header is missing.")
        }
        guard let reservedUsername = await req.authService.redis.v1.getUsername(username),
              reservedUsername.clientOS == clientOS,
              reservedUsername.clientID == clientID
        else {
            throw Abort(.notFound)
        }
        await req.authService.redis.v1.deleteUsername(username)
    }
    
    private func usernameQuery(_ username: String, on db: Database) async throws -> Username? {
        return try await Username
            .query(on: db)
            .filter(\.$username == username)
            .first()
    }
}
