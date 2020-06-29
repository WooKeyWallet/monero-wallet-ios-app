//
//  KeyChain.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/6/10.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit
import Security

class KeyChain: NSObject {
    
    class func configure() {
        if !UserDefaults.standard.bool(forKey: "appDidLaunchedOnLastTime") {
            _=clear()
            UserDefaults.standard.set(true, forKey: "appDidLaunchedOnLastTime")
        }
    }

    class func set(data: Data, forKey: String) -> Bool {
        let queryDic = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: forKey,
            kSecValueData as String: data
            ] as [String : Any]
        let query = queryDic as CFDictionary
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        return status == noErr
    }
    
    class func data(forKey: String) -> Data? {
        let queryDic = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: forKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
            ] as [String : Any]
        let query = queryDic as CFDictionary
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef, {SecItemCopyMatching(query, UnsafeMutablePointer($0))})
        guard status == errSecSuccess else {
            return nil
        }
        return dataTypeRef as? Data
    }
    
    class func remove(forKey: String) -> Bool {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : forKey
            ] as [String : Any]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == noErr
    }
    
    class func clear() -> Bool {
        let query = [ kSecClass as String : kSecClassGenericPassword ]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        return status == noErr
    }
}

// MARK: - KeyChain + string

extension KeyChain {
    
    class func set(string: String, forKey: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return set(data: data, forKey: forKey)
    }
    
    class func string(forKey: String) -> String? {
        if let data = data(forKey: forKey) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

