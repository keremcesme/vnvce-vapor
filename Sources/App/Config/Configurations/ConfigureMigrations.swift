
import Vapor
import FluentPostGIS
import Fluent

extension Application {
    func configureMigrations() async throws {
        self.logger.notice("[ 8/9 ] Configuring Migrations")
        
        let types: [Migration] = [
            CreateMediaType(),
            CreateClientOS(),
            CreateMonth(),
            CreatePaymentProvider(),
            CreateAppStoreTypes(),
            CreateMembershipStatus(),
            CreateMomentAudience()
        ]
        
        let users: [Migration] = [
            CreateUser(),
            CreateUsername(),
            CreateDateOfBirth(),
            CreateSession(),
            CreateNotificationToken(),
            CreateMembership(),
            
        ]
        
        let transactions: [Migration] = [
            CreateAppStoreTransaction()
        ]
        
        let phoneNumbers: [Migration] = [
            CreateCountries(),
            CreatePhoneNumber()
        ]
        
        let relationships: [Migration] = [
            CreateFriendship(),
            CreateFriendRequest(),
            CreateBlock()
        ]
        
        let moments: [Migration] = [
            CreateMoment(),
        ]
        
        let extensions: [Migration] = [
            EnablePostGISMigration(),
            CreatePG_TRGMExtension(),
            CreateUserDisplayNameAndUsernameIndex()
        ]
        
//        self.migrations.add(types)
//        self.migrations.add(users)
//        self.migrations.add(transactions)
//        self.migrations.add(phoneNumbers)
//        self.migrations.add(relationships)
//        self.migrations.add(moments)
//        self.migrations.add(extensions)
        
//      MARK: - NEVER USE ON PRODUCTION -
//        try await self.autoRevert()
//        try await self.autoMigrate()
        
        self.logger.notice("✅ Migrations Configured")
    }
}
