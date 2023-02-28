
import Vapor
import Fluent
import APNS
import APNSwift

extension Request.APNS {
    func sendNotification(
        title: String,
        subtitle: String? = nil,
        body: String,
        userID: User.IDValue,
        targetUserID: User.IDValue,
        req: Request
    ) async throws {
        let alert = APNSwiftAlert(title: title, subtitle: subtitle, body: body)
        
        let payload = APNSwiftPayload(
            alert: alert,
            badge: 1,
            sound: .normal("default"),
            hasContentAvailable: false,
            hasMutableContent: true,
            category: "post",
            threadID: "post_id",
            relevanceScore: 1)
        
        let apn = APNTest(aps: payload, from: userID.uuidString)
        let data = try JSONEncoder().encode(apn)
        let buffer = ByteBuffer(data: data)
        
        guard let notificationToken = try await NotificationToken.query(on: req.db)
            .filter(\.$user.$id == targetUserID)
            .first()?.token else {
            throw Abort(.notFound)
        }
        
        try await req.apns.send(
            rawBytes: buffer,
            pushType: .alert,
            to: notificationToken,
            expiration: nil,
            priority: nil,
            collapseIdentifier: nil,
            topic: nil,
            logger: nil
        )
    }
}
