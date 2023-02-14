
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
            let payload = try req.content.decode(VNVCECore.AppStoreTransaction.V1.self)
            
            guard let userID = payload.appAccountToken,
                  let membership = try await Membership.query(on: req.db).filter(\.$user.$id == userID).first() else {
                throw Abort(.notFound)
            }
            
            let membershipID = try membership.requireID()
            let transactionID = String(payload.id)
            
            let transaction: AppStoreTransaction = try await {
                if let oldTransaction = try await membership.$transactions
                    .query(on: req.db)
                    .filter(\.$id == transactionID)
                    .first() {
                    let transaction = try await req.db.transaction {
                        let newTransaction = payload.convert(membershipID, userID: userID)
                        
                        try await oldTransaction.delete(force: true, on: $0)
                        try await membership.$transactions.create(newTransaction, on: $0)
                        
                        return newTransaction
                    }
                    return transaction
                } else {
                    let transaction = payload.convert(membershipID, userID: userID)
                    try await membership.$transactions.create(transaction, on: req.db)
                    return transaction
                }
            }()
            
            membership.isActive = true
            
            if transaction.offerType == .none {
                if payload.id == payload.originalID {
                    membership.status = .initialBuy
                } else {
                    membership.status = .resubscribe
                }
            } else {
                if payload.id == payload.originalID {
                    membership.status = .offerRedeemedForInitialBuy
                } else {
                    membership.status = .offerRedeemedForResubscribe
                }
            }
            
            if membership.platform == nil || membership.platform != .ios {
                membership.platform = .ios
            }
            
            try await membership.update(on: req.db)
            
            
            return .ok
        case .android:
            throw Abort(.notFound)
        }
        
        
    }
}
