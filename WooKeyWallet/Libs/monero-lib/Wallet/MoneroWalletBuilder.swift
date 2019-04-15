//
//  XMRWalletBuilder.swift
//

import Foundation


public class XMRWalletBuilder {
    
    private var walletPassword: String
    private var walletName: String

    private enum CreateMode {
        case fromScratch
        case fromSeed(seed: Seed)
        case fromKeys(keys: Keys)
        case openExisting
    }
    private var createMode: CreateMode?

    public init()
    {
        self.walletPassword = ""
        self.walletName = ""
    }
    
    public func withPassword(_ password: String, andWalletName walletName: String) -> XMRWalletBuilder {
        self.walletPassword = password
        self.walletName = walletName
        return self
    }
    
    public func fromScratch() -> XMRWalletBuilder {
        self.createMode = .fromScratch
        return self
    }
    
    public func fromSeed(_ seed: Seed) -> XMRWalletBuilder {
        self.createMode = .fromSeed(seed: seed)
        return self
    }
    
    public func fromKeys(_ keys: Keys) -> XMRWalletBuilder {
        self.createMode = .fromKeys(keys: keys)
        return self
    }
    
    public func isValidatePassword() -> Bool {
        return monero_verifyPassword(self.pathWithFileName() + ".keys", walletPassword)
    }
    
    public func openExisting() throws -> XMRWallet {
        let success = self.openExistingWallet()
        
        if success {
            return XMRWallet(walletName: self.walletName)
        }
        throw XMRWalletError.openFailed
    }
    
    public func generate() throws -> XMRWallet {
        var success = false
        
        if let createMode = self.createMode {
            switch createMode {
            case .openExisting:
                success = self.openExistingWallet()
            case .fromScratch:
                success = self.createWalletFromScratch()
            case .fromSeed(let seed):
                success = self.recoverWalletFromSeed(seed)
            case .fromKeys(let keys):
                success = self.recoverWalletFromKeys(keys: keys)
            }
        }

        if success {
            return XMRWallet(walletName: self.walletName)
        }
        throw XMRWalletError.createFailed
    }
    
    
    private func createWalletFromScratch() -> Bool {
        let success = monero_createWalletFromScatch(self.pathWithFileName(),
                                                    self.walletPassword,
                                                    "English")
        return success
    }
    
    private func recoverWalletFromSeed(_ seed: Seed) -> Bool {
        let success = monero_recoverWalletFromSeed(self.pathWithFileName(),
                                                   seed.sentence,
                                                   self.walletPassword)
        return success
    }
    
    private func recoverWalletFromKeys(keys:Keys) -> Bool {
        let success = monero_recoverWalletFromKeys(self.pathWithFileName(), self.walletPassword, "English", keys.restoreHeight, keys.addressString, keys.viewKeyString, keys.spendKeyString)
        return success
    }
    
    private func openExistingWallet() -> Bool {
        let pathWithFile = self.pathWithFileName()
        
        let success = monero_openExistingWallet(pathWithFile,
                                                self.walletPassword)
        return success
    }
    
    private func pathWithFileName() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + self.walletName
        return pathWithFileName
    }
    

}
