//
//  File.swift
//  
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Foundation
import Vapor
import Fluent

private let allowedCharacterSet: CharacterSet = {
    var set = CharacterSet.decimalDigits
    set.insert("+")
    return set
}()

extension String {
    static func randomDigits(ofLength length: Int) -> String {
        guard length > 0 else {
            fatalError("randomDigits must receive length > 0")
        }
        
        var result = ""
        while result.count < length {
            result.append(String(describing: Int.random(in: 0...9)))
        }
        
        return result
    }
    
    static func randomCode(ofLenght lenght: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0 ... 6).map { _ in letters.randomElement()! })
        return code
    }
    
    var removingInvalidCharacters: String {
        return String(unicodeScalars.filter { allowedCharacterSet.contains($0) })
    }
    
    var convertUUID: UUID {
        return UUID(uuidString: self)!
    }
    
}

extension String {
    var fieldKey: FieldKey {
        return FieldKey(stringLiteral: self)
    }
}
