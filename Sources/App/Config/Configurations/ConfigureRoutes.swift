import Vapor
import APNS
import APNSwift
import Leaf
import Redis

enum APIVersions: String {
     case v1 = "v1"
     case v2 = "v2"
}

extension Application {
    public func configureRoutes() throws {
        let jwt = self.grouped("jwt")
        
        try jwtPlayground(self)
        
        jwt.get { req async throws -> String in
            let signed = try req.jwt.sign(JWTExample(test: "Hello world!"), kid: .private)
            let verified = try req.jwt.verify(signed, as: JWTExample.self)
            print(signed)
            
            return signed
        }
        
        self.post("token") { req async -> String in
            
            do {
                let userID = try req.content.decode(UserIDPayload.self).id
                let user = RedisUserIDModel(userID: userID).userID
                
                let key = RedisKey(UUID().uuidString)
                
                try await req.redis.setex(key, toJSON: user, expirationInSeconds: 60)
                
                print("Token is created: Token: \(key)")
                
                return "OK"
            } catch {
                return "ERROR [1]"
            }
        }
        
        self.group(TokenAuthMiddleware()) { m in
            m.get("verify-token") { req async -> String in
                do {
                    let token = try req.auth.require(RedisUserIDModel.self)
                    
                    return "AUTHENTICATED"
                } catch {
                    
                    return "NOT AUTHENTICATED"
                }
            }
        }
        
        self.group("check_token") { check in
            check.group(AccessToken.authenticator(), User.guardMiddleware()) {
                route in
                route.get("test") { req -> HTTPStatus in
                    _ = try req.auth.require(User.self)
                    return .ok
                }
            }
        }
        
        self.get("health") { req  in
            return "OK"
        }
        
    //    self.get { req async in
    //        "It works!"
    //    }
        
        self.get("redis-test") { req async -> String in
            let key = RedisKey("redis-test-key")
            let freshDog = Dog(height: 10, width: 100, url: "url", id: "idexample")
            
            do {
                try await req.redis.setex(key, toJSON: freshDog, expirationInSeconds: 10)
                print("Dog was cached.")
                
                return "REDIS IS WORKED ✅"
            } catch {
                return "REDIS IS NOT WORKED ❌"
            }
        }
        
        self.get("read") { req async throws -> View in
            let dog = try await req.redis.get(RedisKey("cuteDog"), asJSON: Dog.self)
            
            if let dog = dog {
                print(dog)
            }
            
            return try await req.view.render("index")
        }

        
        self.get("sms") { req async -> String in
            
            let code = "000-000"
            let messageType = "vnvce Test"
            
            let message = """
                                  Verification code for \(messageType) account: \(code).
                                  If you did not request this, disregard this message.
                                  """
            do {
                _ = try await req.application.smsSender!
                    .sendSMS(to: "+905533352131", message: message, on: req.eventLoop)
            } catch {
                
            }
            
            
            return "sended"
        }
        
        self.get("push") { req async throws -> String in
            
            let alert = APNSwiftAlert(title: "Title", subtitle: "Subtitle", body: "Body")
            let payload = APNSwiftPayload(
                alert: alert,
                badge: 1,
                sound: .normal("default"),
                hasContentAvailable: false,
                hasMutableContent: true,
                category: "post",
                threadID: "post_id",
                relevanceScore: 1
            )
            let apn = PostAPNTest(aps: payload, from: "asdfasf")
            let data = try JSONEncoder().encode(apn)
            let buffer = ByteBuffer(data: data)
            
            try await req.apns.send(
                rawBytes: buffer,
                pushType: .alert,
                to: "4dfd11dfb3fc85e85b8afae45ef1d975380dbbee9824a40458c521803dcf613d",
                expiration: nil,
                priority: nil,
                collapseIdentifier: nil,
                topic: nil,
                logger: nil
            )
            
            return "sended"
        }
        
        self.get { req in
            req.leaf.render("index")
        }
        
        self.post("upload") { req -> EventLoopFuture<View> in
                struct Input: Content {
                    var file: File
                }
            struct PageContent: Codable {
                var fileUrl: String
                var isImage: String
            }
                let input = try req.content.decode(Input.self)

                guard input.file.data.readableBytes > 0 else {
                    throw Abort(.badRequest)
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "y-m-d-HH-MM-SS-"
                let prefix = formatter.string(from: .init())
                let fileName = prefix + input.file.filename
                let path = self.directory.publicDirectory + fileName
                let isImage = ["png", "jpeg", "jpg", "gif"].contains(input.file.extension?.lowercased())

                return req.application.fileio.openFile(path: path,
                                                       mode: .write,
                                                       flags: .allowFileCreation(posixMode: 0x744),
                                                       eventLoop: req.eventLoop)
                    .flatMap { handle in
                        req.application.fileio.write(fileHandle: handle,
                                                     buffer: input.file.data,
                                                     eventLoop: req.eventLoop)
                            .flatMapThrowing { _ in
                                try handle.close()
                            }
                            .flatMap {
                                let items = PageContent(fileUrl: "\(fileName)", isImage: ".bool(isImage)")
                                return req.leaf.render("result", items)
                            }
                    }
            }
        
        let authController = AuthController()
        try self.register(collection: authController)
        
        let tokenController = TokenController()
        try self.register(collection: tokenController)
        
        let meController = MeController()
        try self.register(collection: meController)
        
        let relationshipController = RelationshipController()
        try self.register(collection: relationshipController)
        
        let searchController = SearchController()
        try self.register(collection: searchController)
        
        let postController = PostController()
        try self.register(collection: postController)
        
        let momentController = MomentController()
        try self.register(collection: momentController)
        
        let userController = UserController()
        try self.register(collection: userController)
        
    }
}


struct PostAPNTest: APNSwiftNotification {
    let aps: APNSwiftPayload
    let from: String

    init(aps: APNSwiftPayload, from: String) {
        self.aps = aps
        self.from = from
    }
}

private func expireTheKey(_ key: RedisKey, redis: Vapor.Request.Redis) {
    //This expires the key after 30s for demonstration purposes
    let expireDuration = TimeAmount.seconds(30)
    _ = redis.expire(key, after: expireDuration)
}

struct Dog: Content, Encodable {
  let height: Int
  let width: Int
  let url: String
  let id: String
}
