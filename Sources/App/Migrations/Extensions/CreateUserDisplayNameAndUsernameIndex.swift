//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.09.2022.
//

import Fluent
import SQLKit

struct CreateUserDisplayNameAndUsernameIndex: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        let displayNameIdx: SQLQueryString = """
                    CREATE INDEX users_display_name_idx
                    ON users
                    USING GIN
                    (\(raw: "display_name".description) gin_trgm_ops)
        """
        
        let usernameIdx: SQLQueryString = """
                    CREATE INDEX usernames_username_idx
                    ON usernames
                    USING GIN
                    (\(raw: "username".description) gin_trgm_ops)
        """
        
        let sqlDatabase = (database as! SQLDatabase)
        try await sqlDatabase.raw(displayNameIdx).run()
        try await sqlDatabase.raw(usernameIdx).run()
    }
    
    func revert(on database: Database) async throws {
        let sqlDatabase = (database as! SQLDatabase)
        try await sqlDatabase
              .raw("DROP INDEX users_display_name_idx")
              .run()
        try await sqlDatabase
              .raw("DROP INDEX usernames_username_idx")
              .run()
    }
}
