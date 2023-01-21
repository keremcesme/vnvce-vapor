import Vapor
import JWT

extension JWKIdentifier {
    static let `public` = JWKIdentifier(string: "public")
    static let `private` = JWKIdentifier(string: "private")
    static let `deviceCheckPrivate` = JWKIdentifier(string: "Q2USH84B88")
}

extension String {
    var bytes: [UInt8] { .init(self.utf8) }
}
