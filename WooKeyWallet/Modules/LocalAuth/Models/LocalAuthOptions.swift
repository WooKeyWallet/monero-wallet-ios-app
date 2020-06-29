//
//  LocalAuthOptions.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import Foundation

public enum LocalAuthOptions: Int {
    case openWallet = 1
    case sendXMR = 2
    case exportKeys = 3
}

extension Array where Element == LocalAuthOptions {
    
    init(rawValues: [Int]?) {
        self = (rawValues ?? []).compactMap({ Element(rawValue: $0) })
    }
}
