
import Vapor
import VNVCECore

extension String {
    var toPathComponents: PathComponent {
        .init(stringLiteral: self)
    }
}

extension Array where Element == String {
    var toPathComponents: [PathComponent] { self.map(PathComponent.init) }
}

extension RouteDefinition {
    var toPathComponents: PathComponent {
        .init(stringLiteral: self.path)
    }
}

extension RouteDefinition {
    var httpMethod: Vapor.HTTPMethod { .init(rawValue: method.rawValue) }
    var pathComponents: Vapor.PathComponent { path.toPathComponents }
}

extension RoutesBuilder {
    @discardableResult
    public func on(
        _ routeDefinition: RouteDefinition,
        use closure: @escaping (Request) async throws -> some AsyncResponseEncodable
    ) -> Route {

        self.on(routeDefinition.httpMethod, routeDefinition.pathComponents, use: closure)
    }

    @discardableResult
    public func on(
        _ routeDefinition: RouteDefinition,
        use closure: @escaping (Request) throws -> some ResponseEncodable
    ) -> Route {
        self.on(routeDefinition.httpMethod, routeDefinition.pathComponents, use: closure)
    }
}

extension HTTPHeaders.Name {
    static let acceptVersion = HTTPHeaders.Name("Accept-version")
}

extension HTTPHeaders {
    public var acceptVersion: String? {
        get {
            guard let string = self.first(name: .acceptVersion) else {
                return nil
            }
            return string
        }
        set {
            if let version = newValue {
                replaceOrAdd(name: .acceptVersion, value: version)
            } else {
                remove(name: .acceptVersion)
            }
        }
    }
}

extension VNVCECore.APIVersion {
    var toPathComponents: PathComponent {
        .init(stringLiteral: self.rawValue)
    }
}
