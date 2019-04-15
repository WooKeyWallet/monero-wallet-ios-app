//
//  Currency.swift


import UIKit

struct Currency {
    let name: String
    let fullName: String
    let icon: UIImage?
    
    init(_ token: Token) {
        name = token.rawValue
        icon = UIImage(named: "token_icon_\(token.rawValue)")
        switch token {
        case .xmr:
            fullName = "Monero"
        default:
            fullName = ""
        }
    }
}
