
import Vapor
import VNVCECore

extension VNVCECore.User.V1.Public: Content {}
extension VNVCECore.User.V1.Private: Content {}
extension User {
    public final class V1 {
        typealias Public = VNVCECore.User.V1.Public
        typealias Private = VNVCECore.User.V1.Private
    }
}

extension VNVCECore.Username.V1: Content {}
extension Username {
    typealias V1 = VNVCECore.Username.V1
}

extension VNVCECore.ProfilePicture.V1: Content {}
extension ProfilePicture {
    typealias V1 = VNVCECore.ProfilePicture.V1
}
