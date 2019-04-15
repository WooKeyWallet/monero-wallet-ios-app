//
//  Common.swift


import Foundation

// MARK: - 

public enum Token: String {
    case xmr = "XMR"
    case dash = "Dash"
    case zcash = "Zcash"
    case eth = "ETH"
}

public enum WooKeyURL: String {
    
    case serviceBook = "https://wallet.wookey.io/service-docs/app.html"
    case moreNodes = "https://wallet.wookey.io/monero-nodes/app.html"
    
    var url: URL {
        return URL(string: rawValue)!
    }
}
