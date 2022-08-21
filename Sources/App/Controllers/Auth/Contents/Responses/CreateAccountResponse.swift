//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Vapor


final class CreateAccountResponse {
    // MARK: V1
    enum V1: Content {
        case success(LoginAccountResponse.V1)
        case failure(SMSVerificationError.V1)
    }
}


//extension AuthController {
//    
//    struct CreateAccountSuccessV1: Content {
//        let user: User.Private
//        let tokens: Tokens
//    }
//    
//    enum CreateAccountStatusV1: Content {
//        case success(CreateAccountSuccessV1)
//        case failure(SMSVerificationResult)
//    }
//    
//    struct CreateAccountResponseV1: Content {
//        let status: CreateAccountStatusV1
//    }
//}
