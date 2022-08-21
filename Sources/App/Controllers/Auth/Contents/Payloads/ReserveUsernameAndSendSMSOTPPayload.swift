//
//  File.swift
//  
//
//  Created by Kerem Cesme on 19.08.2022.
//

import Vapor

final class ReserveUsernameAndSendSMSOTPPayload {
    //MARK: V1
    struct V1: Content {
        let username: String
        let phoneNumber: String
        let clientID: UUID
        let type: SMSType
    }
}
