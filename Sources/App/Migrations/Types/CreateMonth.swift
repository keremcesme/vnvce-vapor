
import Fluent
import FluentPostgresDriver
import Foundation
import VNVCECore

struct CreateMonth: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(Month.schema)
            .case("january")
            .case("february")
            .case("march")
            .case("april")
            .case("may")
            .case("june")
            .case("july")
            .case("august")
            .case("september")
            .case("october")
            .case("november")
            .case("december")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(Month.schema).delete()
    }
}
