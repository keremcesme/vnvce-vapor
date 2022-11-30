
import Vapor
import VNVCECore

extension AuthController {
    public func reserveUsernameAndSendSMSOTPHandler(_ req: Request) async throws -> AnyAsyncResponse {
        guard
            let headerVersion = req.headers.acceptVersion,
            let version = VNVCECore.APIVersion(rawValue: headerVersion) else {
            throw Abort(.notFound)
        }
        
        switch version {
        case .v1:
            return try await reserveUsernameAndSendSMSOTPV1(req)
        default:
            throw Abort(.notFound)
        }
    }
    
    
    private func reserveUsernameAndSendSMSOTPV1(_ req: Request) async throws -> AnyAsyncResponse {
        let p = try req.content.decode(VNVCECore.ReserveUsernameAndSendSMSOTPPayload.V1.self)

        let usernamePayload = CheckUsernamePayload.V1(clientID: p.clientID, username: p.username)
        let usernameAvailability = try await checkUsernameV1(payload: usernamePayload, req)
        
        try await reserveUsernameV1(
            username: p.username,
            clientID: p.clientID,
            availabiltiy: usernameAvailability,
            req)
        
        let phonePayload = CheckPhoneNumberPayload.V1(clientID: p.clientID, phoneNumber: p.phoneNumber)
        let result = try await checkPhoneNumberV1(payload: phonePayload, req)
        let phoneAvailability = result.availability
        
        if phoneAvailability == .notUsed {
            let otp = try await sendSMSOTPV1(
                phoneNumber: p.phoneNumber,
                clientID: p.clientID,
                req)
            return .init(otp)
        } else if phoneAvailability == .otpExpectedBySameUser, let otp = result.otp {
            return .init(otp)
        } else {
            return .init(ResultResponse.V1(error: true, description: phoneAvailability.description))
        }
    }
    
}

extension CheckUsernamePayload.V1: Content {}
