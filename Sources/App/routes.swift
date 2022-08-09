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
}
