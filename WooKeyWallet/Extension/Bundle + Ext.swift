//
//  UIBundle + Ext.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import Foundation

extension Bundle {
    static var wookey: Bundle? {
        guard let bundlePath = Bundle.main.path(forResource: "WooKeyWallet", ofType: "bundle") else { return nil }
        return Bundle(path: bundlePath)
    }
}

