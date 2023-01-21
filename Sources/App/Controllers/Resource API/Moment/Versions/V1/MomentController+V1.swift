////
////  File.swift
////  
////
////  Created by Kerem Cesme on 11.10.2022.
////
//
//import Fluent
//import Vapor
//
//// MARK: MomentController V1 - Route -
//extension MomentController {
//    
//    final class V1 {
//        static let shared = V1()
//        
//        public let version = APIVersion.v1
//        
//        init(){}
//        
//        private let middleware = User.guardMiddleware()
//        
//        func routes(_ routes: RoutesBuilder) {
//            routes.group("api", "test", "moment") { testRoute in
//                testRoute.post("upload", use: uploadMomentTest)
//                testRoute.get("all", use: fetchMomentsTest)
////                testRoute.post("upload2", ":day", ":month", use: uploadMomentHandler2)
////                testRoute.delete("delete_all", use: deleteAllHandler)
////                testRoute.get("all", use: fetchMomentsHandler2)
//            }
//            
//            routes.group(middleware) { secureRoute in
//                secureRoute.group("api", "\(version)", "moment") { momentRoute in
//                    momentRoute.post("upload", use: uploadMomentHandler)
//                    momentRoute.post("fetch", use: fetchMomentsHandler)
//                }
//            }
//        }
//    }
//}
