
import Vapor
import VNVCECore

struct AuthMiddleware: AsyncMiddleware {
    func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
        guard
            let headerVersion = request.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion)
        else {
            throw Abort(.badRequest, reason: "Missing headers.")
        }
        
        switch version {
        case .v1:
            try await authorizationV1(request)
        default:
            throw Abort(.badRequest, reason: "Version `\(headerVersion)` is not available for this request.")
        }
        
        return try await next.respond(to: request)
    }
    
    
}
