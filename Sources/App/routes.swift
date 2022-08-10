import Vapor

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
}
