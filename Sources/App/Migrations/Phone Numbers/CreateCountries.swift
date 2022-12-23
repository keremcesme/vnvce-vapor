
import Fluent
import SQLKit
import PostgresKit
import FluentSQL

struct CreateCountries: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let createSequence: SQLQueryString = "CREATE SEQUENCE country_seq"
        let createTable: SQLQueryString = """
        CREATE TABLE IF NOT EXISTS countries (
        id int NOT NULL DEFAULT NEXTVAL ('country_seq'),
        iso char(2) NOT NULL,
        name varchar(80) NOT NULL,
        nicename varchar(80) NOT NULL,
        iso3 char(3) DEFAULT NULL,
        numcode smallint DEFAULT NULL,
        phonecode int NOT NULL,
        PRIMARY KEY (id)
        )
        """
        
        let sqlDatabase = (database as! SQLDatabase)
        
        try await sqlDatabase.raw(createSequence).run()
        try await sqlDatabase.raw(createTable).run()
        try await sqlDatabase.raw(countriesData).run()
    }
    
    func revert(on database: Database) async throws {
        let dropTable: SQLQueryString = "DROP TABLE countries"
        let dropSequence: SQLQueryString = "DROP SEQUENCE country_seq"
        
        let sqlDatabase = (database as! SQLDatabase)
        try await sqlDatabase.raw(dropTable).run()
        try await sqlDatabase.raw(dropSequence).run()
    }
}

