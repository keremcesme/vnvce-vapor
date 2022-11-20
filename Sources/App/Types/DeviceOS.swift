//
//  File.swift
//  
//
//  Created by Kerem Cesme on 18.11.2022.
//

import Foundation

enum DeviceOS: String, Codable {
    case ios, android
    
    static let schema =  "device_os"
}
