
import Vapor
import Fluent
import VNVCECore

extension MomentController {
    public func requestIdHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await requestIdV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func requestIdV1(_ req: Request) async throws -> UUID {
        let id: UUID = try await {
            var id: UUID?
            while id == nil {
                let candidateID = UUID()
                if try await Moment.query(on: req.db).filter(\.$id == candidateID).first() == nil {
                    id = candidateID
                    break
                }
            }
            return id!
        }()
        
        return id
    }
}

extension UUID: Content {}
