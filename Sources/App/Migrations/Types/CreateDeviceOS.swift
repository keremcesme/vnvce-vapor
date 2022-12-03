//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Fluent
import VNVCECore

struct CreateDeviceOS: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database
            .enum(DeviceOS.schema)
            .case("ios")
            .case("android")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.enum(DeviceOS.schema).delete()
    }
}
