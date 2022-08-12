//
//  File.swift
//  
//
//  Created by Kerem Cesme on 10.08.2022.
//

import Vapor

func runMigrations(_ app: Application) {
    app.migrations.add([
        CreateUser(),
        CreatePhoneNumber(),
        CreateUsername(),
        CreateSMSVerificationAttempt(),
        CreateReservedUsername()
    ])
}
