import Foundation

final private class Regex {
    static let shared = Regex()
    
    fileprivate enum RegexType: String {
        case username = "^(?=.{3,20}$)(?=.*?[a-zA-Z]{2})(?![._])(?!.*[_.]{2})[a-zA-Z0-9._]+$"
        case phoneNumber = ""
    }
    
    init() {}
    
    public func validate(_ value: String, type: RegexType) -> Bool {
//        let inputpred = NSPredicate(format: "SELF MATCHES %@", type.rawValue)
//        return inputpred.evaluate(with: value)
        
        let range = NSRange(location: 0, length: value.utf16.count)
        let regex = try! NSRegularExpression(pattern: type.rawValue)
        return regex.firstMatch(in: value, options: [], range: range) != nil
        
    }
}

extension String {
    func validateUsername() -> Bool {
        Regex.shared.validate(self, type: .username)
    }
    
    func validatePhoneNumber() -> Bool {
        Regex.shared.validate(self, type: .phoneNumber)
    }
}
