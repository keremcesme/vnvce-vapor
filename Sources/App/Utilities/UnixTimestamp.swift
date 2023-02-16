
import Foundation

typealias UnixTimestamp = Int

extension UnixTimestamp {
    /// Unix timestamp to date.
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self / 1_000)) // must take a millisecond-precise Unix timestamp
    }
}

extension TimeInterval {
    var date: Date {
        return .init(timeIntervalSince1970: self)
    }
}
