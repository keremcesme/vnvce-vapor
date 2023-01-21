
import Vapor

extension Application {
    public func configureRoutes() async throws {
        self.logger.notice("[ 6/8 ] Configuring Routes")
        
        // MARK: AWS Health Check
        self.get("health") { _ in
            return HTTPStatus(statusCode: 200)
        }
        
        // MARK: Controllers
        let authController = AuthController()
        let resourceController = ResourceController()
        
        // MARK: APIs
        let versionMiddleware = VersionMiddleware()
        let api = self.grouped("api")
            .grouped(versionMiddleware)
        
        try api.register(collection: authController)
        try api.register(collection: resourceController)
        
        // MARK: ONLY FOR DEVELOPMENT
//        try routesPlayground()
        
        self.logger.notice("✅ Routes Configured")
    }
}



























// MARK: TRASH
//extension Application {
//
//    private func routesPlayground() throws {
//        self.get("redis-test", use: { req async -> String in
//
//            let key = RedisKey("test-key")
//
//            do {
//                try await req.redis.setex(key, toJSON: "Test Redis Value", expirationInSeconds: 60)
//
//                guard let value = try await req.redis.get(key, asJSON: String.self) else {
//                    return "Not Work [1]"
//                }
//
//                return "WORK! [\(value)]"
//
//            } catch let error {
//                return "Not Work [2] \(error.localizedDescription)"
//            }
//        })
//
//        if let teamID = Environment.get("APPLE_TEAM_ID")
//        {
//
//            let deviceCheck = DeviceCheck(jwkKid: .deviceCheckPrivate, jwkIss: teamID)
//
//            self.get("device-check") { req in
//
//                guard let xAppleDeviceToken = req.headers.first(name: .xAppleDeviceToken) else {
//                    return "No Auth Token"
//                }
//
//                let url = URI(string: "https://api.development.devicecheck.apple.com/v1/validate_device_token")
////                Q2USH84B88
//                let jwtPayload = DeviceCheckJWT(iss: teamID)
//
//                let jwt = try req.jwt.sign(jwtPayload, kid: .deviceCheckPrivate)
//
////                var headers = HTTPHeaders()
////                headers.add(name: .authorization, value: "Bearer \(jwt)")
////
//                let content = DeviceCheckRequest(deviceToken: xAppleDeviceToken)
////
////                let result = req.client.post(url, headers: headers, content: content)
//                print(content)
//                print("~~~~~~~~~~~~~~~~~~~~")
//                print(jwt)
//                print("~~~~~~~~~~~~~~~~~~~~")
//
//                return jwt
//            }
//
//
//
//            self.get("version-test") { req -> String in
////                print(req.headers.acceptVersion)
//                print(req.headers)
//                return ""
//            }
//
//        }
//
//
//
////        self.group(deviceCheck) { route in
////            route.get("health") { req  in
////                return "OK"
////            }
////        }
//
//        let jwt = self.grouped("jwt")
//
//        try jwtPlayground(self)
//
//        jwt.get { req async throws -> String in
//            let signed = try req.jwt.sign(JWTExample(test: "Hello world!"), kid: .private)
//            let verified = try req.jwt.verify(signed, as: JWTExample.self)
//            print(signed)
//
//            return signed
//        }
//
//    //    self.get { req async in
//    //        "It works!"
//    //    }
//
//
//        self.get("read") { req async throws -> View in
//            let dog = try await req.redis.get(RedisKey("cuteDog"), asJSON: Dog.self)
//
//            if let dog = dog {
//                print(dog)
//            }
//
//            return try await req.view.render("index")
//        }
//
//
//        self.get("sms") { req async -> String in
//
//            let code = "000-000"
//            let messageType = "vnvce Test"
//
//            let message = """
//                                  Verification code for \(messageType) account: \(code).
//                                  If you did not request this, disregard this message.
//                                  """
////            do {
////                _ = try await req.application.smsSender!
////                    .sendSMS(to: "+905533352131", message: message, on: req.eventLoop)
////            } catch {
////
////            }
//
//
//            return "sended"
//        }
//
//        self.get("push") { req async throws -> String in
//
//            let alert = APNSwiftAlert(title: "Title", subtitle: "Subtitle", body: "Body")
//            let payload = APNSwiftPayload(
//                alert: alert,
//                badge: 1,
//                sound: .normal("default"),
//                hasContentAvailable: false,
//                hasMutableContent: true,
//                category: "post",
//                threadID: "post_id",
//                relevanceScore: 1
//            )
//            let apn = PostAPNTest(aps: payload, from: "asdfasf")
//            let data = try JSONEncoder().encode(apn)
//            let buffer = ByteBuffer(data: data)
//
//            try await req.apns.send(
//                rawBytes: buffer,
//                pushType: .alert,
//                to: "4dfd11dfb3fc85e85b8afae45ef1d975380dbbee9824a40458c521803dcf613d",
//                expiration: nil,
//                priority: nil,
//                collapseIdentifier: nil,
//                topic: nil,
//                logger: nil
//            )
//
//            return "sended"
//        }
//
//        self.get { req in
//            req.leaf.render("index")
//        }
//
//        self.post("upload") { req -> EventLoopFuture<View> in
//                struct Input: Content {
//                    var file: File
//                }
//            struct PageContent: Codable {
//                var fileUrl: String
//                var isImage: String
//            }
//                let input = try req.content.decode(Input.self)
//
//                guard input.file.data.readableBytes > 0 else {
//                    throw Abort(.badRequest)
//                }
//
//                let formatter = DateFormatter()
//                formatter.dateFormat = "y-m-d-HH-MM-SS-"
//                let prefix = formatter.string(from: .init())
//                let fileName = prefix + input.file.filename
//                let path = self.directory.publicDirectory + fileName
//                let isImage = ["png", "jpeg", "jpg", "gif"].contains(input.file.extension?.lowercased())
//
//                return req.application.fileio.openFile(path: path,
//                                                       mode: .write,
//                                                       flags: .allowFileCreation(posixMode: 0x744),
//                                                       eventLoop: req.eventLoop)
//                    .flatMap { handle in
//                        req.application.fileio.write(fileHandle: handle,
//                                                     buffer: input.file.data,
//                                                     eventLoop: req.eventLoop)
//                            .flatMapThrowing { _ in
//                                try handle.close()
//                            }
//                            .flatMap {
//                                let items = PageContent(fileUrl: "\(fileName)", isImage: ".bool(isImage)")
//                                return req.leaf.render("result", items)
//                            }
//                    }
//            }
//    }
//}
//
//struct PostAPNTest: APNSwiftNotification {
//    let aps: APNSwiftPayload
//    let from: String
//
//    init(aps: APNSwiftPayload, from: String) {
//        self.aps = aps
//        self.from = from
//    }
//}
//
//private func expireTheKey(_ key: RedisKey, redis: Vapor.Request.Redis) {
//    //This expires the key after 30s for demonstration purposes
//    let expireDuration = TimeAmount.seconds(30)
//    _ = redis.expire(key, after: expireDuration)
//}
//
//struct Dog: Content, Encodable {
//  let height: Int
//  let width: Int
//  let url: String
//  let id: String
//}
