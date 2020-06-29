//
//  MarketsModel.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/11.
//  Copyright © 2020 Wookey. All rights reserved.
//

import Foundation

struct MarketsModel {
    
    let icon: UIImage?
    let coinText: String
    let amountText: String
    let legalText: String
    let xmrPriceText: String
    
    init(coin: String, amount: Double?, legal: String, xmrAmount: Double?) {
        self.icon = UIImage(named: "\(coin)_icon")
        self.coinText = coin.uppercased()
        self.legalText = legal.uppercased()
        if let amount = amount {
            self.amountText = String(amount)
            if let xmrAmount = xmrAmount {
                self.xmrPriceText = String(format: "≈ %.2f XMR", amount / xmrAmount)
            } else {
                self.xmrPriceText = "--"
            }
        } else {
            self.amountText = "--"
            self.xmrPriceText = "--"
        }        
    }
}
