//
//  File.swift
//  
//
//  Created by Kerem Cesme on 21.08.2022.
//

import Fluent
import Vapor


struct TokenController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        v1routes(routes: routes)
    }
}

extension TokenController {
    
    func v1routes(routes: RoutesBuilder)  {
        routes.group("api", "\(APIVersions.v1)", "token") { token in
//            token.post("generate", use: generateNewTokens)
//            token.group(AccessToken.authenticator(), User.guardMiddleware()) { secure in
//                secure.get("validate", use: accessTokenValidation)
//            }
//            routeV1.post("generate_tokens", use: getNewAccessToken)
//            routeV1.group(AccessToken.authenticator(), User.guardMiddleware()) { protectedV1 in
//                protectedV1.get("validate_access_token", use: accessTokenValidation)
//            }
            
            
        }
    }
    
}
