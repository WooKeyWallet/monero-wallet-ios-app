//
//  Assets.swift


import UIKit

struct Assets {
    
    var id: Int = 0
    var icon: UIImage?
    var token: String = ""
    var remain: String = ""
    
    
    var wallet: TokenWallet?
    
    init(asset: Asset) {
        self.id = asset.id
        self.icon = UIImage(named: "token_icon_\(asset.token)")
        self.token = asset.token
        if let balance = asset.balance {
            self.remain = Helper.displayDigitsAmount(balance)
        } else {
            self.remain = "--"
        }
    }
}
