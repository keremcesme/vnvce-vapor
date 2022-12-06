import Vapor
import VNVCECore

enum ConfigurePhase: Logger.Message {
    case asdf = "asdf"
}

enum ConfigureError: Logger.Message, Error {
    case missingDBEnvironments = "❌ Missing DB Environments"
    case missingRedisEnvironments = "❌ Missing Redis Environments"
    
    case missingRSAKeys = "❌ Missing RSA keys for JWT"
    case missingRSAPublicKey = "❌ Missing RSA public key for JWT"
    case missingRSAPrivateKey = "❌ Missing RSA private keyfor JWT"
    
    case missingAWSEnvironments = "❌ Missing AWS Environments"
    case missingAppleAPNSEnvironments = "❌ Missing Apple APNs Environments"
}

public func configure(_ app: Application) async throws {
    
    let key = "-----BEGIN RSA PRIVATE KEY-----\n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\n-----END RSA PRIVATE KEY-----"

//    print(key)
    
//    app.http.server.configuration.supportPipelining = true
//    app.http.server.configuration.responseCompression = .enabled
//    app.http.server.configuration.requestDecompression = .enabled
//    app.http.server.configuration.tcpNoDelay = true
    
//    let string = String(Environment.get("TEST")!)
    
//    print(string.replacingOccurrences(of: "\\n", with: "\n"))
    
    switch app.environment {
    case .production:
        app.logger.notice("[ MODE ] Running in Production")
    default:
        app.logger.notice("[ MODE ] Running in Development")
    }
    
    app.logger.notice("Total Configurations: 8")
    
    try await app.configureDatabase()
    try await app.configureRedis()
//    try await app.configureAppleAPN()
//    try await app.configureAWSSMS()
    try await app.configureJWT()
    try await app.configureRoutes()

    await app.configureMigrations()
    await app.configureViews()
    
    app.logger.notice("✅ Configurations Success")
    
    
//    try app.configureAppleDeviceCheck()
    
//    try app.autoRevert().wait()
//    try app.autoMigrate().wait()
    
}




//-----BEGIN RSA PRIVATE KEY-----
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
//-----END RSA PRIVATE KEY-----

//-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoHXDivYXaI7zb9GG76QC\nzstH5PuvUhjCG/Y6cZKoF1+alhFuays5e+OxBfesYTy9QEDzo+sDH5qRN/aBF8gf\naCeIiQbKKakNYwkuP2xOcovd4xeNv35QLnXmPl4QW9aP2AWT8konEp8vsIUZfI7Q\nk6LZ/EbHUFXq3uW5lqjXkUY6JB2h3KzlOAixO9VnvsYzoi9APBbl0Z+ax+RhAsnh\nK/6OxxWwTxf9aykWMqMrFBmWmpJdPCUWKmRqySBl8ieZULFdK/lE677DH3zOAf/D\n1Nf6n10Wf7kB4e77eZog1I9M/Gg6y9qTnAb0SoL4nyS+8Uy90SnZZL11Oi8gxaVA\n7oXpTCxstK+XIjpMX9EwICVMTG45oxZBl7SEMMJsLjvCQx6ccrqDucrtGreGHg6T\n88Y6qumpxgqbDYsGQU+EfDTUo1zcqc/2mG6Nmapdrc3EDngWLwcOoewQtEST32Td\nvZOb7fAugThyJHieCYSX6VL16WGHNHvYHxarpdBSh5BYt0om97EJP/WSw8dECYyO\noI9D4OnWCNcCw6RqWMgECW13IzYGhsokU42cZqsq8zPO8OMmrXcUfcm/O1lS7+n1\n0tlJz1erDg/XL6B2lNYEuIoV9bTHyIqj34c4XH9Gq30+DWvv277ZsCLdkYH9X0Tk\nwr0eD6pt8P8W6rqSav9idY8CAwEAAQ==\n-----END PUBLIC KEY-----


