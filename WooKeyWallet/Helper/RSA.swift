//
//  RSA.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/6/10.
//  Copyright © 2020 Wookey. All rights reserved.
//

import Foundation
import SwiftyRSA

struct RSA {
    
    let data: Data?
    let string: String
    
    init(encrypt text: String) {
        do {
            let key = try PublicKey(base64Encoded: Keys.publicKey)
            let clear = try ClearMessage(string: text, using: .utf8)
            let encrypted = try clear.encrypted(with: key, padding: .PKCS1)
            self.data = encrypted.data
            self.string = encrypted.base64String
        } catch {
            self.data = text.data(using: .utf8)
            self.string = text
            dPrint("- RSA Encrypt Error - {\(error)}")
        }
    }
    
    init(decrypt text: String) {
        do {
            let key = try PrivateKey(base64Encoded: Keys.privateKey)
            let encrypted = try EncryptedMessage(base64Encoded: text)
            let clear = try encrypted.decrypted(with: key, padding: .PKCS1)
            self.string = try clear.string(encoding: .utf8)
            self.data = clear.data
        } catch {
            self.data = text.data(using: .utf8)
            self.string = text
            dPrint("- RSA Decrypted Error - {\(error)}")
        }
    }
}

private extension RSA {
    
    private struct Keys {
        fileprivate static let publicKey: String = {
            return ""
        }()
        
        fileprivate static var privateKey: String {
            return ""
        }
    }
}
