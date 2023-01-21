
import Vapor
import FluentKit

struct PaginationResponse<T: Content>: Content {
    public var items: [T]
    public var metadata: PageMetadata
    
    public init(
        items: [T] = [],
        metadata: PageMetadata = .init(page: 0, per: 0, total: 0)
    ) {
        self.items = items
        self.metadata = metadata
    }
}
