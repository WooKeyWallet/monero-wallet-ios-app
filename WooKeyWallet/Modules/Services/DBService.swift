//
//  DBService.swift


import UIKit
import WCDBSwift


class DBService: NSObject {
    
    // MARK: - Properties (Public)
    
    static let shared = { return DBService() }()
    
    
    // MARK: - Properties (Private)

    private lazy var database: Database = {
        return Database(withPath: "Wookey/DB/app.db".filePaths.document)
    }()
    
    
    // MARK: - Methods (Private)
    
    private func recoverIfNeed() {
        Database.globalTrace(ofError: {
            (err: WCDBSwift.Error) in
            dPrint(err)
            
        })
    }
    
    private func tryCreateTables() {
        do {
            try database.create(table: DBTableNames.wallets, of: Wallet.self)
            try database.create(table: DBTableNames.nodes, of: Node.self)
            try database.create(table: DBTableNames.assets, of: Asset.self)
            try database.create(table: DBTableNames.address_books, of: Address.self)
            try database.create(table: DBTableNames.transactions, of: _Transaction_.self)
        } catch {
            dPrint(error)
        }
    }
    
    
    // MARK: - Methods (Public)
    
    func setup() {
        recoverIfNeed()
        tryCreateTables()
    }
    
    
    func insertWallet(_ wallet: Wallet) -> Bool {
        var status = wallet.isValidate()
        guard status else {
            return false
        }
        do {
            if WalletDefaults.shared.walletsCount == 0 {
                wallet.isActive = true
            }
            try database.insert(objects: wallet, intoTable: DBTableNames.wallets)
            WalletDefaults.shared.walletsCount += 1
            if let db_wallet = getWallets(Wallet.CodingKeys.name == wallet.name && Wallet.CodingKeys.symbol == wallet.symbol)?.first {
                let asset = Asset.init()
                asset.token = db_wallet.symbol
                asset.balance = db_wallet.balance
                asset.walletId = db_wallet.id
                try database.insert(objects: asset, intoTable: DBTableNames.assets)
            }
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func deleteWallet(_ condition: Condition) -> Bool {
        var status = true
        do {
            try database.delete(fromTable: DBTableNames.wallets, where: condition)
            WalletDefaults.shared.walletsCount -= 1
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func updateWallet(on: [Wallet.Properties], with: Wallet, condition: Condition) -> Bool {
//        var status = with.isValidate()
//        guard status else {
//            return false
//        }
        var status = true
        do {
            try database.update(table: DBTableNames.wallets,
                                on: on,
                                with: with,
                                where: condition)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func getWallets(_ condition: Condition? = nil, orderBy: [OrderBy]? = nil) -> [Wallet]? {
        var result: [Wallet]?
        do {
            let codingKeys: [PropertyConvertible] = Wallet.Properties.all
            result = try database.getObjects(on: codingKeys,
                                             fromTable: DBTableNames.wallets,
                                             where: condition,
                                             orderBy: orderBy)
        } catch {
            dPrint(error)
        }
        return result
    }
    
    func getAssets(_ condition: Condition? = nil, orderBy: [OrderBy]? = nil) -> [Asset]?  {
        var result: [Asset]?
        do {
            let codingKeys: [PropertyConvertible] = Asset.Properties.all
            result = try database.getObjects(on: codingKeys,
                                             fromTable: DBTableNames.assets,
                                             where: condition,
                                             orderBy: orderBy)
        } catch {
            dPrint(error)
        }
        return result
    }
    
    func update(on: [Asset.Properties], with: Asset, condition: Condition) -> Bool {
        var status = true
        do {
            try database.update(table: DBTableNames.assets,
                                on: on,
                                with: with,
                                where: condition)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func getNodeList(_ condition: Condition? = nil, orderBy: [OrderBy]? = nil) -> [Node]? {
        var result: [Node]?
        do {
            let codingKeys: [PropertyConvertible] = Node.Properties.all
            result = try database.getObjects(on: codingKeys,
                                             fromTable: DBTableNames.nodes,
                                             where: condition,
                                             orderBy: orderBy)
        } catch {
            dPrint(error)
        }
        return result
    }
    
    func insertNode(_ node: Node) -> Bool {
        var status = node.isValidate()
        guard status else {
            return false
        }
        do {
            try database.insert(objects: node, intoTable: DBTableNames.nodes)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func deleteNode(_ url: String) -> Bool {
        var status = true
        do {
            try database.delete(fromTable: DBTableNames.nodes, where: Node.Properties.url.is(url), orderBy: nil, limit: nil, offset: nil)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func update(on: [Node.Properties], with: Node, condition: Condition) -> Bool {
        var status = true
        do {
            try database.update(table: DBTableNames.nodes,
                                on: on,
                                with: with,
                                where: condition)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func getAddressList(_ condition: Condition? = nil, orderBy: [OrderBy]? = nil) -> [Address]? {
        var result: [Address]?
        do {
            let codingKeys: [PropertyConvertible] = Address.Properties.all
            result = try database.getObjects(on: codingKeys,
                                             fromTable: DBTableNames.address_books,
                                             where: condition,
                                             orderBy: orderBy)
        } catch {
            dPrint(error)
        }
        return result
    }
    
    func insertAddress(_ obj: Address) -> Bool {
        var status = obj.insertValid
        guard status else {
            return false
        }
        do {
            try database.insert(objects: obj, intoTable: DBTableNames.address_books)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func update(on: [Address.Properties], with: Address, condition: Condition) -> Bool {
        var status = true
        do {
            try database.update(table: DBTableNames.address_books,
                                on: on,
                                with: with,
                                where: condition)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func deleteAddress(_ condition: Condition) -> Bool {
        var status = true
        do {
            try database.delete(fromTable: DBTableNames.address_books, where: condition)
        } catch {
            dPrint(error)
            status = false
        }
        return status
    }
    
    func getTransactionList(condition: Condition, orderBy: [OrderBy]? = nil) -> [Transaction]? {
        do {
            let codingKeys: [PropertyConvertible] = _Transaction_.Properties.all
            let list: [_Transaction_] = try database.getObjects(on: codingKeys,
                                                                fromTable: DBTableNames.transactions,
                                                                where: condition,
                                                                orderBy: orderBy,
                                                                limit: nil)
            return list.map({ $0.value() })
        } catch {
            dPrint(error)
            return nil
        }
    }
    
    func insertTransactions(list: [Transaction], walletId: Int) -> Bool {
        do {
            try database.begin()
            try database.insert(objects: list.map({ _Transaction_.from($0, walletId: walletId) }), intoTable: DBTableNames.transactions)
            try database.commit()
            return true
        } catch {
            dPrint(error)
            return false
        }
    }
    
    func removeAllTransactions(condition: Condition) -> Bool {
        do {
            try database.begin()
            try self.database.delete(fromTable: DBTableNames.transactions, where: condition)
            try database.commit()
            return true
        } catch {
            dPrint(error)
            return false
        }
    }
}
