
import Vapor
import VNVCECore

public struct VersionMiddleware: AsyncMiddleware {
    public func respond(
        to request: Request,
        chainingTo next: AsyncResponder
    ) async throws -> Vapor.Response {
        guard let versionHeader = request.headers.acceptVersion else {
            throw Abort(.notFound)
        }
        
        guard VNVCECore.APIVersion(rawValue: versionHeader) != nil else {
            throw Abort(.notFound)
        }
        
        return try await next.respond(to: request)
    }
}
 
