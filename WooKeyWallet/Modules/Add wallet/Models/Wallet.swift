//
//  Wallet.swift


import Foundation

public struct WalletRecovery {
    
    enum From {
        case seed
        case keys
    }
    
    var seed: String?
    var address: String?
    var viewKey: String?
    var spendKey: String?
    var block: String?
    var date: Date?
    
    let from: From
    
    init(from: From) {
        self.from = from
    }
    
    func validateNext() -> Bool {
        switch from {
        case .seed:
            return seed != nil && seed!.count > 0
        case .keys:
            return viewKey != nil && viewKey!.count > 0 && spendKey != nil && spendKey!.count > 0 && address != nil && address!.count > 0
        }
    }
    
    func getKeys() -> Keys? {
        guard
            let addr = address,
            addr.count > 0,
            let viewKey = viewKey,
            viewKey.count > 0,
            let spendKey = spendKey,
            spendKey.count > 0
        else {
            return nil
        }
        var restoreHeight: UInt64 = 0
        if let block = block {
            restoreHeight = UInt64(block) ?? 0
        } else if let date = date {
            restoreHeight = date.getBlockHeight()
        }
        return Keys.init(restoreHeight: restoreHeight, addressString: addr, viewKeyString: viewKey, spendKeyString: spendKey)
    }
}

public struct WalletCreate {
    
    enum Mode {
        case new
        case recovery
    }
    
    var mode: Mode = .new
    var token: Token?
    var name: String?
    var pwd: String?
    var pwdTips: String?
    
    var recovery: WalletRecovery?
}




