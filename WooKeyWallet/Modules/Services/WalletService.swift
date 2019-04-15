//
//  WalletService.swift


import Foundation

public protocol WalletProtocol {
    var seed: Seed? { get }
    var balance: String { get }
    var unlockedBalance: String { get }
    var secretViewKey: String { get }
    var secretSpendKey: String { get }
    var publicViewKey: String { get }
    var publicSpendKey: String { get }
    var publicAddress: String { get }
    var restoreHeight: UInt64 { get set }
    var history: TransactionHistory { get }
    var synchronized: Bool { get }
    func connectToDaemon(address: String, upperTransactionSizeLimit: UInt64, daemonUsername: String, daemonPassword: String) -> Bool
    func setListener(listenerHandler: (() -> Void)?, newBlockHandler: ((UInt64,  UInt64) -> Void)?)
    func refresh()
    func pasueRefresh()
    func lock()
    
    func generatePaymentId() -> String
    func generateIntegartedAddress(_ paymentId: String) -> String
    func validAddress(_ address: String) -> Bool
    
    func createPendingTransaction(_ dstAddress: String, paymentId: String, amount: String) -> Bool
    func createSweepTransaction(_ dstAddress: String, paymentId: String) -> Bool
    func getTransactionFee() -> String?
    func commitPendingTransaction() -> Bool
    func disposeTransaction()
    func commitPendingTransactionError() -> String
    
    func displayAmount(_ value: UInt64) -> String
    
    func storeSycnhronized()
    
}

public enum WalletError: Error {
    case noWalletName
    case noSeed
    
    case createFailed
    case openFailed
}

extension XMRWallet: WalletProtocol {
    
}


public class WalletService {
    
    // MARK: - Properties (Public)
    
    public static let shared: WalletService = { return WalletService() }()
    
    public var hasProceedWallet: Bool {
        get {
            return WalletDefaults.shared.proceedWalletID != nil
        }
    }
    public var hasWallets: Bool {
        get {
            return WalletDefaults.shared.walletsCount > 0
        }
    }
    
    lazy var walletActiveState = { Observable<Int?>(nil) }()
    lazy var assetRefreshState = { Observable<Int?>(nil) }()
    
    
    // MARK: - Properties (Private)
    
    private var createdWallet: WalletProtocol?
    
    private lazy var safeQueue = { DispatchQueue(label: "XMRWallet-Queue", qos: .default) }()
    
    // MARK: - Methods (Public)
    
    public static func validAddress(_ addr: String, symbol: String) -> Bool {
        if symbol == "XMR" {
            return XMRWallet.init(walletName: "").validAddress(addr)
        }
        return false
    }
    
    public func safeOperation(_ excute: (() -> Void)?) {
        guard let call = excute else { return }
        safeQueue.async(execute: call)
    }
    
    public func createWallet(_ create: WalletCreate) throws -> WalletProtocol  {
        switch create.token! {
        case .xmr:
            let walletBuilder = XMRWalletBuilder.init()
            var _wallet: WalletProtocol?
            switch create.mode {
            case .new:
                _wallet = try walletBuilder.withPassword(create.pwd!, andWalletName: create.name!).fromScratch().generate()
            case .recovery:
                guard let recovery = create.recovery else { throw WalletError.createFailed }
                switch recovery.from {
                case .seed:
                    if let seedStr = recovery.seed, let seed = Seed.init(sentence: seedStr) {
                        _wallet = try walletBuilder.withPassword(create.pwd!, andWalletName: create.name!).fromSeed(seed).generate()
                    }
                case .keys:
                    guard let keys = recovery.getKeys() else { throw WalletError.createFailed }
                    _wallet = try walletBuilder.withPassword(create.pwd!, andWalletName: create.name!).fromKeys(keys).generate()
                }
            }
            guard
                let wallet = _wallet,
                insertWallet(wallet, create: create)
            else {
                throw WalletError.createFailed
            }
            self.createdWallet = wallet
            return wallet
        default:
            throw WalletError.createFailed
        }
    }
    
    public func verifyPassword(_ name: String, password: String) -> Bool {
        return XMRWalletBuilder().withPassword(password, andWalletName: name).isValidatePassword()
    }
    
    public func loginWallet(_ name: String, password: String) throws -> WalletProtocol {
        let wallet = try XMRWalletBuilder().withPassword(password, andWalletName: name).openExisting()
        return wallet
    }
    
    func createFinish() {
        guard let wallet = self.createdWallet else { return }
        safeOperation {
            wallet.lock()
        }
        self.createdWallet = nil
    }
    
    func getActiveWallet() -> Wallet? {
        return DBService.shared.getWallets(Wallet.CodingKeys.isActive.is(true))?.first
    }
    
    func getWallets() -> [Wallet] {
        return DBService.shared.getWallets() ?? []
    }
    
    func getAssets(_ walletId: Int) -> [Assets] {
        let db_assets = DBService.shared.getAssets(Asset.CodingKeys.walletId.is(walletId), orderBy: nil) ?? []
        return db_assets.map({
            Assets.init(asset: $0)
        })
    }
    
    func updateActiveWallet(_ walletId: Int) -> Bool {
        if let old_wallet = getActiveWallet() {
            old_wallet.isActive = false
            if !DBService.shared.updateWallet(on: [Wallet.Properties.isActive], with: old_wallet, condition: Wallet.Properties.id.is(old_wallet.id)) {
                return false
            }
        }
        let new_wallet = Wallet()
        new_wallet.id = walletId
        new_wallet.isActive = true
        return DBService.shared.updateWallet(on: [Wallet.Properties.isActive], with: new_wallet, condition: Wallet.Properties.id.is(walletId))
    }
    
    // MARK: - Methods (Private)
    
    private func insertWallet(_ wallet: WalletProtocol, create: WalletCreate) -> Bool {
        /// 循环等待公钥地址
        while true {
            if wallet.publicAddress != "" {
                break
            }
        }
        
        let db_wallet = Wallet()
        db_wallet.name = create.name!
        db_wallet.symbol = create.token!.rawValue
        db_wallet.address = wallet.publicAddress
        db_wallet.passwordPrompt = create.pwdTips
        if create.mode == .recovery, let recovery = create.recovery {
            if let block = recovery.block, let date = recovery.date {
                let block = UInt64(block) ?? 0
                let date_block = date.getBlockHeight()
                if block > 0 {
                    db_wallet.restoreHeight = block
                } else {
                    db_wallet.restoreHeight = date_block
                }
            } else if let block = recovery.block {
                db_wallet.restoreHeight = UInt64(block)
            } else if let date = recovery.date {
                db_wallet.restoreHeight = date.getBlockHeight()
            } else {
                db_wallet.restoreHeight = 0
            }
        }
        db_wallet.isActive = false
        
        return DBService.shared.insertWallet(db_wallet)
    }

}
