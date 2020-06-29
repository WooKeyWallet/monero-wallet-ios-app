//
//  WalletService.swift


import Foundation

public enum WalletError: Error {
    case noWalletName
    case noSeed
    
    case createFailed
    case openFailed
}

class WalletService {
    
    typealias GetWalletHandler = (Result<XMRWallet, WalletError>) -> Void
    
    // MARK: - Properties (static)
    
    static let shared = { WalletService() }()
    
    
    // MARK: - Properties (public)
        
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
    
    
    // MARK: - Properties (public lazy)
    
    lazy var walletActiveState = { Observable<Int?>(nil) }()
    lazy var assetRefreshState = { Observable<Int?>(nil) }()
    
    
    // MARK: - Methods (Public)
    
    public static func validAddress(_ addr: String, symbol: String) -> Bool {
        if symbol == "XMR" {
            return MoneroWalletWrapper.validAddress(addr)
        }
        return false
    }
    
    public func verifyPassword(_ name: String, password: String) -> Bool {
        return XMRWalletBuilder(name: name, password: password).isValidatePassword()
    }
    
    public func createWallet(with style: CreateWalletStyle, result: GetWalletHandler?) {
        DispatchQueuePool.shared["XMRWallet:new"].async {
            var result_wallet: XMRWallet?
            switch style {
            case .new(let data):
                result_wallet = XMRWalletBuilder(name: data.name, password: data.pwd).fromScratch().generate()
            case .recovery(let data, let recover):
                switch recover.from {
                case .seed:
                    if let seedStr = recover.seed, let seed = Seed.init(sentence: seedStr) {
                        result_wallet = XMRWalletBuilder(name: data.name, password: data.pwd).fromSeed(seed).generate()
                    }
                case .keys:
                    if let keys = recover.getKeys() {
                        result_wallet = XMRWalletBuilder(name: data.name, password: data.pwd).fromKeys(keys).generate()
                    }
                }
            }
            guard let wallet = result_wallet,
                self.insertWallet(wallet, createStyle: style)
            else {
                result?(.failure(WalletError.createFailed))
                return
            }
            do { // 配置当前使用的钱包
                if WalletDefaults.shared.walletsCount > 1 {
                    let condition = Wallet.Properties.name.is(wallet.walletName)
                    if let db_wallet = DBService.shared.getWallets(condition, orderBy: nil)?.first,
                        self.updateActiveWallet(db_wallet.id) {
                        DispatchQueue.main.async {
                            self.walletActiveState.value = db_wallet.id
                        }
                    }
                }
            }
            wallet.setSubAddress(LocalizedString(key: "primaryAddress", comment: ""), rowId: 0, result: { (success) in
                result?(.success(wallet))
            })
        }
    }
    
    public func openWallet(_ name: String, password: String, result: GetWalletHandler?) {
        DispatchQueuePool.shared["XMRWallet:" + name].async {
            if let wallet = XMRWalletBuilder(name: name, password: password).openExisting() {
                result?(.success(wallet))
            } else {
                result?(.failure(.openFailed))
            }
        }
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
    
    func disableWalletActive() -> Bool {
        guard let old_wallet = getActiveWallet() else {
            return false
        }
        old_wallet.isActive = false
        return DBService.shared.updateWallet(on: [Wallet.Properties.isActive],
                                                    with: old_wallet,
                                                    condition: Wallet.Properties.id.is(old_wallet.id))
    }
    
    func updateActiveWallet(_ walletId: Int) -> Bool {
        guard disableWalletActive() else {
            return false
        }
        let new_wallet = Wallet()
        new_wallet.id = walletId
        new_wallet.isActive = true
        return DBService.shared.updateWallet(on: [Wallet.Properties.isActive],
                                             with: new_wallet,
                                             condition: Wallet.Properties.id.is(walletId))
    }
    
    func removeWallet(_ name: String) -> Bool {
        do {
            let docUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let paths: [String] = try FileManager.default.contentsOfDirectory(atPath: docUrl.path).map({ docUrl.appendingPathComponent($0).path })
            /// 如果存在就删除
            try paths.forEach {
                var isDir = ObjCBool(false)
                if FileManager.default.fileExists(atPath: $0, isDirectory: &isDir),
                    !isDir.boolValue,
                    URL(fileURLWithPath: $0).lastPathComponent.hasPrefix(name),
                    FileManager.default.isDeletableFile(atPath: $0)
                {
                    try FileManager.default.removeItem(atPath: $0)
                }
            }
            /// 必须删除
            while true {
                if DBService.shared.deleteWallet(Wallet.Properties.name.is(name)) { break }
            }
            
            return true
        } catch {
            dPrint(error)
            return false
        }
    }
    
    
    
    // MARK: - Methods (Private)
        
    private func insertWallet(_ wallet: XMRWallet, createStyle: CreateWalletStyle) -> Bool {
        /// 循环等待公钥地址
        while true {
            if wallet.publicAddress != "" {
                break
            }
        }
        
        let db_wallet = Wallet()
        db_wallet.name = wallet.walletName
        db_wallet.symbol = "XMR"
        db_wallet.address = wallet.publicAddress
        db_wallet.isActive = false
        
        switch createStyle {
        case .new(let data):
            db_wallet.passwordPrompt = data.pwdTips
        case .recovery(let data, let recover):
            db_wallet.passwordPrompt = data.pwdTips
            if let block = recover.block, let date = recover.date {
                let block = UInt64(block) ?? 0
                let date_block = date.getBlockHeight()
                if block > 0 {
                    db_wallet.restoreHeight = block
                } else {
                    db_wallet.restoreHeight = date_block
                }
            } else if let block = recover.block {
                db_wallet.restoreHeight = UInt64(block)
            } else if let date = recover.date {
                db_wallet.restoreHeight = date.getBlockHeight()
            } else {
                db_wallet.restoreHeight = 0
            }
        }
                
        return DBService.shared.insertWallet(db_wallet)
    }

}
