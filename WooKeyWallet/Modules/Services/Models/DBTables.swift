//
//  DBTables.swift


import Foundation
import WCDBSwift


public struct DBTableNames {
    static let wallets = "wallets"
    static let assets = "assets"
    static let nodes = "nodes"
    static let address_books = "address_books"
    static let transactions = "transactions"
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

class _Transaction_: TableCodable {
    var id: Int = 0
    var walletId: Int = 0
    var type: Int = 0
    var amount: String = ""
    var status: Int = 0
    var token: String = ""
    var date: Date = Date.init(timeIntervalSince1970: 0)
    var fee: String = ""
    var paymentId: String = ""
    var hash: String = ""
    var block: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = _Transaction_
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, orderBy: .ascending, isAutoIncrement: true, onConflict: nil, isNotNull: false, isUnique: false)
            ]
        }
        case id
        case walletId
        case type
        case amount
        case status
        case token
        case date
        case fee
        case paymentId
        case hash
        case block
    }
    
    var isAutoIncrement: Bool = true
}

extension _Transaction_ {
    
    func value() -> Transaction {
        return Transaction(type: TransactionsType(rawValue: type) ?? .all,
                           amount: amount,
                           status: Transaction.Status(rawValue: status) ?? .failure,
                           token: token,
                           date: date.toString("yyyy-MM-dd HH:mm:ss"),
                           fee: fee,
                           paymentId: paymentId,
                           hash: hash,
                           block: block)
    }
    
    class func from(_ value: Transaction, walletId: Int) -> _Transaction_ {
        let model = _Transaction_.init()
        model.walletId = walletId
        model.type = value.type.rawValue
        model.amount = value.amount
        model.status = value.status.rawValue
        model.token = value.token
        model.date = Date.from(value.date, formatt: "yyyy-MM-dd HH:mm:ss") ?? Date.init(timeIntervalSince1970: 0)
        model.fee = value.fee
        model.paymentId = value.paymentId
        model.hash = value.hash
        model.block = value.block
        return model
    }
}
