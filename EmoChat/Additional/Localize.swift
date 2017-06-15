//https://www.packtpub.com/books/content/string-management-in-swift

import Foundation

private extension String {
    var snakeCaseString: String {
        return replacingOccurrences(of:"([a-z])([A-Z])", with: "$1-$2", options: .regularExpression, range: startIndex..<endIndex)
            .replacingCharacters(in: startIndex..<startIndex, with: String(self[startIndex]))
            .lowercased()
    }
}

private let stringSeparator: String = "."

public protocol Localizable {
    static var parent: LocalizeParent { get }
    var rawValue: String { get }
}

public typealias LocalizeParent = Localizable.Type?

public extension Localizable {
    var localized: String {
        return Bundle.main.localizedString(forKey: localizableKey, value: nil, table: nil)
    }
    
    var description: String {
        return localizableKey
    }
}

private extension Localizable {
    static func concatComponent(parent: String?, child: String) -> String {
        guard let p = parent else { return child.snakeCaseString }
        return p + stringSeparator + child.snakeCaseString
    }
    
    static var entityName: String {
        return String(describing: self)
    }
    
    static var entityPath: String {
         return concatComponent(parent: parent?.entityName, child: entityName)
    }
    
    var localizableKey: String {
        return type(of: self).concatComponent(parent: type(of: self).entityPath, child: rawValue)
    }
}

