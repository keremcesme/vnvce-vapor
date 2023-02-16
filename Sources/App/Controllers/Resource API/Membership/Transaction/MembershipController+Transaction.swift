
import Vapor
import Fluent
import VNVCECore

extension MembershipController {
    public func transactionHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion)
        else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await transactionV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    private func transactionV1(_ req: Request) async throws -> HTTPStatus {
        guard let clientOS = req.headers.clientOS?.convertClientOS else {
            throw Abort(.notFound)
        }
        
        _ = try req.auth.require(User.self)
        
        switch clientOS {
        case .ios:
            
            req.logger.notice("HERE 1")
            let transaction = try req.content.decode(VNVCECore.AppStoreTransaction.V1.self)
            let userID = transaction.appAccountToken
            req.logger.notice("HERE 2")
            guard let membership = try await Membership.query(on: req.db).filter(\.$user.$id == userID).first() else {
                throw Abort(.notFound)
            }
            
            req.logger.notice("HERE 3")
            
            if let currentTransaction = try await AppStoreTransaction.find(transaction.id, on: req.db) {
                try await transaction.update(currentTransaction, on: req.db)
            } else {
                req.logger.notice("HERE 4")
                try await transaction.create(membership, on: req.db)
                
            }
            
            membership.isActive = true
            membership.provider = .appleAppStore
            
            try await membership.update(on: req.db)
            
            return .ok
        case .android:
            throw Abort(.notFound)
        }
        
        
    }
}
