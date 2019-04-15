//
//  DBTables.swift


import Foundation
import WCDBSwift


public struct DBTableNames {
    static let wallets = "wallets"
    static let assets = "assets"
    static let nodes = "nodes"
    static let address_books = "address_books"
}


class Wallet: TableCodable {
    var id: Int = 0
    var symbol: String = ""
    var name: String = ""
    var address: String = ""
    var balance: String?
    var passwordPrompt: String?
    var restoreHeight: UInt64?
    var isActive: Bool = false
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Wallet
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, orderBy: .ascending, isAutoIncrement: true, onConflict: nil, isNotNull: false, isUnique: false)
            ]
        }
        case id
        case symbol
        case name
        case address
        case balance
        case passwordPrompt
        case restoreHeight
        case isActive
    }
    
    var isAutoIncrement: Bool = true
    
    func isValidate() -> Bool {
        guard
            self.address.count > 0,
            self.name.count > 0,
            self.symbol.count > 0
        else {
            return false
        }
        return true
    }
}

class Asset: TableCodable {
    var id: Int = 0
    var walletId: Int = 0
    var token: String = ""
    var balance: String?
    var contractAddress: String?

    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Asset
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, orderBy: .ascending, isAutoIncrement: true, onConflict: nil, isNotNull: false, isUnique: false)
            ]
        }
        case id
        case walletId
        case token
        case balance
        case contractAddress
    }
    
    var isAutoIncrement: Bool = true
}

class Node: TableCodable {
    var id: Int = 0
    var symbol: String = ""
    var url: String = ""
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Node
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, orderBy: .ascending, isAutoIncrement: true, onConflict: nil, isNotNull: false, isUnique: false)
            ]
        }
        case id
        case symbol
        case url
        case isSelected
    }
    
    var isAutoIncrement: Bool = true
    
    func isValidate() -> Bool {
        guard
            self.url.count > 0,
            self.symbol.count > 0
        else {
                return false
        }
        return true
    }
}

class Address: TableCodable {
    var id: Int = 0
    var symbol: String = ""
    var address: String = ""
    var notes: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Address
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, orderBy: .ascending, isAutoIncrement: true, onConflict: nil, isNotNull: false, isUnique: false)
            ]
        }
        case id
        case symbol
        case address
        case notes
    }
    
    var isAutoIncrement: Bool = true
    
    var insertValid: Bool {
        return symbol.count > 0 && address.count > 0 && notes.count > 0
    }
}
