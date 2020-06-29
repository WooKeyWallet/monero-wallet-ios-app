//
//  SubAddress.swift
//  Wookey
//
//  Created by WookeyWallet on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import Foundation

public struct SubAddress: Equatable, Codable {
    var rowId: Int = 0
    var address: String = ""
    var label: String = ""
    
    init() {}
    init(model: MoneroSubAddress) {
        self.rowId = model.rowId
        self.address = model.address
        self.label = model.label
    }
    
    static func primary(address: String) -> SubAddress {
        var model = SubAddress()
        model.rowId = -1
        model.address = address
        model.label = LocalizedString(key: "primaryAddress", comment: "")
        return model
    }
}
