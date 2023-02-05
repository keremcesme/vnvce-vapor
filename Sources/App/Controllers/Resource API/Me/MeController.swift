
import Vapor
import Fluent

// MARK: MeController - Version Routes -
struct MeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("me")
        
        api.get("profile", use: profileHandler)
        
        let edit = api.grouped("edit")
        edit.patch("display-name", use: editDisplayNameHandler)
        edit.patch("biography", use: editBiographyHandler)
        edit.patch("profile-picture", use: editProfilePictureHandler)
        
    }
}
