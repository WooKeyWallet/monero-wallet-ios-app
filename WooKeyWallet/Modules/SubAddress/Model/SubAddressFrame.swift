//
//  SubAddressFrame.swift
//  Wookey
//
//  Created by jowsing on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import Foundation

struct SubAddressFrame {
    
    let label: String
    let address: String
    let optionIcon: UIImage?
    
    init(model: SubAddress, address: String) {
        self.label = model.label
        self.address = model.address
        if let subAddr = WalletDefaults.shared.subAddressIndexs[address] {
            if subAddr == model.address {
                self.optionIcon = UIImage(named: "node_option_selected")
            } else {
                self.optionIcon = UIImage(named: "node_option_normal")
            }
        } else {
            if model.rowId == -1 {
                self.optionIcon = UIImage(named: "node_option_selected")
            } else {
                self.optionIcon = UIImage(named: "node_option_normal")
            }
        }
    }
}
