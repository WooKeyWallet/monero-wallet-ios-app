//
//  XMRWallet.swift
//

import Foundation

public enum XMRWalletError: Error {
    case noWalletName
    case noSeed
    
    case createFailed
    case openFailed
}


func xmr_displayAmount(_ value: UInt64) -> String {
    return String(cString: monero_displayAmount(value))
}

public class XMRWallet {
    
    fileprivate var walletName: String
    
    private var listenerHandler: (() -> Void)?
    private var newBlockHandler: ((UInt64,  UInt64) -> Void)?
    
    
    public init(walletName: String)
    {
        self.walletName = walletName
    }
}

extension XMRWallet {
    
    public func connectToDaemon(address: String, upperTransactionSizeLimit: UInt64,
                                daemonUsername: String = "",
                                daemonPassword: String = "") -> Bool
    {
        let status = monero_init(address, 0, daemonUsername, daemonPassword)
        return status
    }
    
    public func pasueRefresh() {
        monero_pauseRefresh()
    }
    
    public func refresh() {
        monero_startRefresh()
    }
    
    public func lock() {
        self.listenerHandler = nil
        self.newBlockHandler = nil
        if !monero_closeWallet() {
            print("========================================================================关闭失败")
        }
    }
    
    public func setNewPassword(_ password: String) {
        monero_setNewPassword(password)
    }
    
    public var restoreHeight: UInt64 {
        get { return monero_getRestoreHeight() }
        set {
            monero_setRestoreHeight(newValue)
        }
    }

    public var secretViewKey: String {
        get {
            let str = String(cString: monero_getSecretViewKey())
            return str
        }
    }

    public var secretSpendKey: String {
        get {
            let str = String(cString: monero_getSecretSpendKey())
            return str
        }
    }
    
    public var publicViewKey: String {
        get {
            let str = String(cString: monero_getPublicViewKey())
            return str
        }
    }
    public var publicSpendKey: String {
        get {
            let str = String(cString: monero_getPublicSpendKey())
            return str
        }
    }
    
    public var publicAddress: String {
        get {
            let str = String(cString: monero_getPublicAddress())
            return str
        }
    }
    
    public var seed: Seed? {
        get {
            let sentence = String(cString: monero_getSeed("English"))
            return Seed(sentence: sentence)
        }
    }
    
    public var synchronized: Bool {
        return monero_isSynchronized();
    }

    public var balance: String {
        return String(cString: monero_displayAmount(monero_getBalance()))
    }

    public var unlockedBalance: String {
        return String(cString: monero_displayAmount(monero_getUnlockedBalance()))
    }
    
    public var history: TransactionHistory {
        return self.getUpdatedHistory()
    }
    
    public func storeSycnhronized() -> Bool {
        return monero_store(self.pathWithFileName())
    }

    public func generatePaymentId() -> String {
        return String(cString: monero_getPatmentId())
    }

    public func generateIntegartedAddress(_ paymentId: String) -> String {
        return String(cString: monero_getIntegartedAddress(paymentId))
    }

    public func validAddress(_ address: String) -> Bool {
        return monero_isValidWalletAddress(address)
    }

    public func createPendingTransaction(_ dstAddress: String, paymentId: String, amount: String) -> Bool {
        return monero_createTransaction(dstAddress,
                                        paymentId,
                                        monero_getAmountFromString(amount),
                                        10,
                                        monero_pendingTransactionPriority(rawValue: 0))
    }
    
    public func createSweepTransaction(_ dstAddress: String, paymentId: String) -> Bool {
        return monero_createSweepTransaction(dstAddress, paymentId, 10, monero_pendingTransactionPriority(0))
    }
    
    public func getTransactionFee() -> String? {
        let fee = monero_getTransactionFee()
        if fee < 0 {
            return nil
        }
        return xmr_displayAmount(UInt64(fee))
    }
    
    public func disposeTransaction() {
        monero_disposeTransaction()
    }

    public func commitPendingTransaction() -> Bool {
        return monero_commitPendingTransaction()
    }
    
    public func commitPendingTransactionError() -> String {
        return String(cString: monero_commitPendingTransactionErrorString())
    }

    public func displayAmount(_ value: UInt64) -> String {
        return xmr_displayAmount(value)
    }
    
    private func getUpdatedHistory() -> TransactionHistory {
        let transactionHistory = TransactionHistory()

        guard let moneroHistory = monero_getTrxHistory() else { return transactionHistory }
        guard let transactions = moneroHistory.pointee.transactions else { return transactionHistory }
        let numberOfTransactions = moneroHistory.pointee.numberOfTransactions

        var unorderedHistory = [TransactionItem]()
        let swiftTransactions = InteropConverter.convert(data: transactions, elementCount: Int(numberOfTransactions))
        for swiftTransaction in swiftTransactions {
            if let swiftTransaction = swiftTransaction?.pointee {
                let historyItem = TransactionItem(direction: TransactionDirection(rawValue: Int(swiftTransaction.direction.rawValue))!,
                                                  isPending: swiftTransaction.isPending,
                                                  isFailed: swiftTransaction.isFailed,
                                                  amount: swiftTransaction.amount,
                                                  networkFee: swiftTransaction.fee,
                                                  timestamp: UInt64(swiftTransaction.timestamp),
                                                  paymentId: String(cString: swiftTransaction.paymentId),
                                                  hash: String(cString: swiftTransaction.hash),
                                                  label: String(cString: swiftTransaction.label),
                                                  blockHeight: swiftTransaction.blockHeight,
                                                  confirmations: swiftTransaction.confirmations)
                unorderedHistory.append(historyItem)
            }
        }

        monero_deleteHistory(moneroHistory)

        // in reverse order: latest to oldest
        transactionHistory.all = unorderedHistory.sorted{ return $0.timestamp > $1.timestamp }
        return transactionHistory
    }
    
    public func setListener(listenerHandler: (() -> Void)?, newBlockHandler: ((UInt64,  UInt64) -> Void)?) {
        self.listenerHandler = listenerHandler
        self.newBlockHandler = newBlockHandler
        let handler = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        monero_registerListenerCallbacks(
            handler,
            { (handler) in
                if let handler = handler {
                    let mySelf = Unmanaged<XMRWallet>.fromOpaque(handler).takeUnretainedValue()
                    mySelf.listenerHandler?()
                }},
            { (handler,currentHeight,blockChainHeight)  in
                if let handler = handler {
                    let mySelf = Unmanaged<XMRWallet>.fromOpaque(handler).takeUnretainedValue()
                    mySelf.newBlockHandler?(currentHeight, blockChainHeight)
                }}
        )
    }
    
    private func pathWithFileName() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + self.walletName
        print("### WALLET LOCATION: \(pathWithFileName)")
        return pathWithFileName
    }
    
}


















