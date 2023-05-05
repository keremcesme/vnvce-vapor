
import Vapor
import VNVCECore

extension VNVCECore.Moment.V1.Public: Content {}
extension VNVCECore.Moment.V1.Private: Content {}

extension Moment {
    public final class V1 {
        typealias Public = VNVCECore.Moment.V1.Public
        typealias Private = VNVCECore.Moment.V1.Private
    }
}
