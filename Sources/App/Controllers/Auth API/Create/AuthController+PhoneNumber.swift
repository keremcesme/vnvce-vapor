
import Vapor
import VNVCECore

extension AuthController {
    public func checkPhoneNumberHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard let headerVersion = req.headers.acceptVersion,
              let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            let result = try await checkPhoneNumberV1(req)
            return .init(result)
        default:
            throw Abort(.notFound)
        }
    }
    
    public func checkPhoneNumberV1(_ req: Request) async throws -> RequestResponse.V1 {
        let phoneNumber = try req.query.decode(CheckPhoneNumberParams.V1.self).phoneNumber
        let otp = req.authService.otp.v1
        let availability =  try await otp.checkPhoneNumber(phoneNumber: phoneNumber, reason: .create, on: req)
        
        if availability == .notUsed || availability == .otpExpectedBySameUser {
            return .init(error: false)
        } else {
            return .init(error: true, message: "Phone number cannot be used.")
        }
    }
    
}
