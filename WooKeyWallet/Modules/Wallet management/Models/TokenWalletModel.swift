//
//  TokenWalletModel.swift


import Foundation

struct TokenWallet {
    var id: Int = 0
    var label: String = ""
    var token: String = ""
    var amount: String = ""
    var icon: UIImage?
    var address: String = ""
    var in_use: Bool = false
    var restoreHeight: UInt64?
    var pwdTips: String = ""
    
    init() {
        
    }
    
    init(_ wallet: Wallet) {
        self.id = wallet.id
        self.label = wallet.name
        self.token = wallet.symbol
        if let balance = wallet.balance {
            self.amount = Helper.displayDigitsAmount(balance)
        } else {
            self.amount = "--"
        }
        self.icon = UIImage(named: "token_icon_\(wallet.symbol)")
        self.address = wallet.address
        self.in_use = wallet.isActive
        self.restoreHeight = wallet.restoreHeight
        self.pwdTips = wallet.passwordPrompt ?? LocalizedString(key: "none", comment: "")
    }
    
    func getToken() -> Token {
        return Token(rawValue: token) ?? .xmr
    }
    
    func displayAddress() -> String {
        return WalletDefaults.shared.subAddressIndexState.value[address]?.address ?? address
    }
    
}
