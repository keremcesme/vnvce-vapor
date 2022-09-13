//
//  File.swift
//  
//
//  Created by Buse tunçel on 31.08.2022.
//

import Fluent
import Vapor

final class PostOwner: Model, Content {
    static let schema = "post_owners"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "owner_id")
    var owner: User
    
    @OptionalParent(key: "co_post_owner_id")
    var coOwner: User?
    
    @OptionalEnum(key: "co_post_approval_status")
    var approvalStatus: CoPostApprovalStatus?
    
    @OptionalChild(for: \.$owner)
    var post: Post?
    
    init(){}
    
    init(
        owner : User.IDValue,
        coOwner : User.IDValue? = nil,
        approvalStatus: CoPostApprovalStatus? = nil
    ){
        self.$owner.id = owner
        self.$coOwner.id = coOwner
        self.approvalStatus = approvalStatus
    }
    
    struct V1: Content {
        let owner: User.Public
        let coOwner: User.Public?
        let approvalStatus: CoPostApprovalStatus?
        
        init(owner: User.Public,
             coOwner: User.Public? = nil,
             approvalStatus: CoPostApprovalStatus? = nil) {
            self.owner = owner
            self.coOwner = coOwner
            self.approvalStatus = approvalStatus
        }
    }
}

extension PostOwner {
    
    func convertV1(
        owner: User,
        coOwner: User? = nil,
        on req: Request
    ) async throws -> PostOwner.V1 {
        let publicOwner = try await owner.convertToPublic(req)
        
        if let coOwner = coOwner {
            let publicCoOwner = try await coOwner.convertToPublic(req)
            return PostOwner.V1(owner: publicOwner,
                                coOwner: publicCoOwner,
                                approvalStatus: self.approvalStatus)
        } else {
            return PostOwner.V1(owner: publicOwner)
        }
    }
    
    func convertV1(
        owner: User,
        coOwner: User? = nil,
        on db: Database
    ) async throws -> PostOwner.V1 {
        let publicOwner = try await owner.convertToPublic(db)
        
        if let coOwner = coOwner {
            let publicCoOwner = try await coOwner.convertToPublic(db)
            return PostOwner.V1(owner: publicOwner,
                                coOwner: publicCoOwner,
                                approvalStatus: self.approvalStatus)
        } else {
            return PostOwner.V1(owner: publicOwner)
        }
    }
    
    func convertV1(
        owner: User.Public,
        coOwner: User.Public? = nil
    ) -> PostOwner.V1 {
        return PostOwner.V1(owner: owner,
                            coOwner: coOwner,
                            approvalStatus: self.approvalStatus)
    }
    
    func convertPostOwner(db: Database) async throws -> PostOwner.V1 {
        try await self.$owner.load(on: db)
        try await self.$coOwner.load(on: db)
        
        let owner = try await self.owner.convertToPublic(db)
        let coOwner = try await self.coOwner?.convertToPublic(db)
        
        return PostOwner.V1(owner: owner, coOwner: coOwner, approvalStatus: self.approvalStatus)
    }
}
