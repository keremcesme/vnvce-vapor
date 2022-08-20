import Vapor
import APNS
import APNSwift

enum APIVersions: String {
     case v1 = "v1"
     case v2 = "v2"
}

func routes(_ app: Application) throws {
    
    app.get("health") { req  in
        return "OK"
    }
    
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("sms") { req async -> String in
        
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
    
    app.get("push") { req async throws -> String in
        
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
    
    let authController = AuthController()
    try app.register(collection: authController)
    
    let tokenController = TokenController()
    try app.register(collection: tokenController)
}

struct PostAPNTest: APNSwiftNotification {
    let aps: APNSwiftPayload
    let from: String

    init(aps: APNSwiftPayload, from: String) {
        self.aps = aps
        self.from = from
    }
}
