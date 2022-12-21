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

extension String {
    func uuid() throws -> UUID {
        let uuid = UUID(uuidString: self)
        
        guard let uuid else {
            throw NSError(domain: "String dont convert to UUID", code: 0)
        }
        
        return uuid
    }
}

extension String {
    var key: String {
        return self.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    var convertToKey: String {
        return self.replacingOccurrences(of: "\\n", with: "\n")
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
