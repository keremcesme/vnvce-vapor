//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Vapor
import SotoS3

class AWSS3: S3Protocol {
    private let s3: S3
    
    init(accessKeyID: String, secretAccessKey: String) {
        let client = AWSClient(
            credentialProvider: .static(
                accessKeyId: accessKeyID,
                secretAccessKey: secretAccessKey),
            httpClientProvider: .createNew)
        
        self.s3 = S3(client: client, region: .eucentral1)
    }
    
    func upload() async throws -> Bool {
        return true
    }
}
