
import Foundation
import VNVCECore
import FluentPostGIS

//extension GeometricPoint2D {
//    public var convert: MomentLocation {
//        return .init(latitude: self.x, longitude: self.y)
//    }
//}

extension Optional where Wrapped == GeometricPoint2D {
    public var convert: MomentLocation? {
        if let location = self.wrapped {
            return .init(latitude: location.x, longitude: location.y)
        } else {
            return nil
        }
        
    }
}
