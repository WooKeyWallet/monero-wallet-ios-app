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


private func xmr_path(with name: String) -> String {
    let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = allPaths[0]
    let documentPath = documentDirectory + "/"
    let pathWithFileName = documentPath + name
    print("### WALLET LOCATION: \(pathWithFileName)")
    return pathWithFileName
}



public class XMRWallet {
    
    // MARK: - Properties (public)
    
    public let walletName: String
    
    
    // MARK: - Properties (private)
    
    private let language: String
    private let walletWrapper: MoneroWalletWrapper
    private let safeQueue: DispatchQueue
    
    private var isClosing = false
    private var isSaving = false
    private var isClosed = false
    
    private var needSaveOnTerminate = false
    
    private var didEnterBackground: NSObjectProtocol?
    private var willTerminate: NSObjectProtocol?
    
    
    // MARK: - Life Cycles
    
    public init(walletWrapper: MoneroWalletWrapper) {
        self.language = "English"
        self.walletWrapper = walletWrapper
        self.walletName = walletWrapper.name
        self.safeQueue = DispatchQueuePool.shared["XMRWallet:" + walletName]
    }
    
    public func saveOnTerminate() {
        guard !needSaveOnTerminate else {
            return
        }
        needSaveOnTerminate = true
        let saveOnAppTerminateHandler = { [weak self] (notification: Notification) in
            guard let SELF = self else { return }
            SELF.save()
        }
        didEnterBackground = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil, using: saveOnAppTerminateHandler)
        willTerminate = NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil, using: saveOnAppTerminateHandler)
    }
    
    public func connectToDaemon(address: String, refresh: @escaping MoneroWalletRefreshHandler, newBlock: @escaping MoneroWalletNewBlockHandler) -> Bool {
        return walletWrapper.connect(toDaemon: address, refresh: refresh, newBlock: newBlock)
    }
    
    public func connectToDaemon(address: String, delegate: MoneroWalletDelegate, result: @escaping (Bool) -> Void) {
        safeQueue.async {
            result(self.walletWrapper.connect(toDaemon: address, delegate: delegate))
        }
    }
    
    public func setDelegate(_ delegate: MoneroWalletDelegate) {
        walletWrapper.setDelegate(delegate)
    }
    
    public func pasue() {
        walletWrapper.pauseRefresh()
    }
    
    public func start() {
        walletWrapper.startRefresh()
    }
    
    public func close() {
        guard !isClosed else {
            return
        }
        if needSaveOnTerminate {
            self.save()
        }
        self.isClosing = true
        safeQueue.async {
            if self.walletWrapper.close() {
                self.isClosing = false
                self.isClosed = true
            } else {
                Thread.sleep(forTimeInterval: 0.2)
                self.close()
            }
        }
    }
    
    public func save() {
        guard !isClosing || !isSaving else {
            return
        }
        self.isSaving = true
        safeQueue.async {
            self.walletWrapper.save()
            self.isSaving = false
        }
    }
    
    public func createPendingTransaction(_ dstAddress: String, paymentId: String, amount: String) -> Bool {
        return walletWrapper.createTransaction(toAddress: dstAddress, paymentId: paymentId, amount: amount, mixinCount: 10, priority: .default)
    }
    
    public func createSweepTransaction(_ dstAddress: String, paymentId: String) -> Bool {
        return walletWrapper.createSweepTransaction(toAddress: dstAddress, paymentId: paymentId, mixinCount: 10, priority: .default)
    }

    public func commitPendingTransaction() -> Bool {
        return walletWrapper.commitPendingTransaction()
    }
    
    public func commitPendingTransactionError() -> String {
        return walletWrapper.transactionErrorMessage()
    }
    
    public func disposeTransaction() {
        walletWrapper.disposeTransaction()
    }
        
}

extension XMRWallet {
    
    public func setNewPassword(_ password: String) {
        walletWrapper.setNewPassword(password)
    }
    public var blockChainHeight: UInt64 {
        return walletWrapper.blockChainHeight
    }
    public var daemonBlockChainHeight: UInt64 {
        return walletWrapper.daemonBlockChainHeight
    }
    public var restoreHeight: UInt64 {
        get { return walletWrapper.restoreHeight }
        set {
            walletWrapper.restoreHeight = newValue
        }
    }
    public var secretViewKey: String {
        return walletWrapper.secretViewKey
    }
    public var secretSpendKey: String {
        return walletWrapper.secretSpendKey
    }
    public var publicViewKey: String {
        return walletWrapper.publicViewKey
    }
    public var publicSpendKey: String {
        return walletWrapper.publicSpendKey
    }
    public var publicAddress: String {
        return walletWrapper.publicAddress
    }
    public var seed: Seed? {
        let sentence = walletWrapper.getSeedString(language)
        return Seed(sentence: sentence)
    }
    public var synchronized: Bool {
        return walletWrapper.isSynchronized
    }
    public var balance: String {
        return displayAmount(walletWrapper.balance)
    }
    public var unlockedBalance: String {
        return displayAmount(walletWrapper.unlockedBalance)
    }
    
    public var history: TransactionHistory {
        return self.getUpdatedHistory()
    }

    public func generatePaymentId() -> String {
        return MoneroWalletWrapper.generatePaymentId()
    }

    public func generateIntegartedAddress(_ paymentId: String) -> String {
        return walletWrapper.generateIntegartedAddress(paymentId)
    }
    
    public func addSubAddress(_ label: String, result: ((Bool) -> Void)?) {
        safeQueue.async {
            result?(self.walletWrapper.addSubAddress(label, accountIndex: 0))
        }
    }
    
    public func setSubAddress(_ label: String, rowId: Int, result: ((Bool) -> Void)?) {
        safeQueue.async {
            result?(self.walletWrapper.setSubAddress(label, addressIndex: UInt32(rowId), accountIndex: 0))
        }
    }
    
    public func getAllSubAddress() -> [SubAddress] {
        let list = walletWrapper.fetchSubAddress(withAccountIndex: 0).map({SubAddress.init(model: $0)})
        dPrint(" >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \(list)")
        return list
    }
    
    public func getTransactionFee() -> String? {
        let fee = walletWrapper.transactionFee()
        if fee < 0 {
            return nil
        }
        return MoneroWalletWrapper.displayAmount(UInt64(fee))
    }

    public func displayAmount(_ value: UInt64) -> String {
        return MoneroWalletWrapper.displayAmount(value)
    }
    
    private func getUpdatedHistory() -> TransactionHistory {
        let unorderedHistory = walletWrapper.fetchTransactionHistory().map({TransactionItem(model: $0)})
        // in reverse order: latest to oldest
        let list = unorderedHistory.sorted{ return $0.timestamp > $1.timestamp }
        return TransactionHistory(list)
    }
    
}
