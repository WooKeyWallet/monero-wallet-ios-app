//
//  XMRWalletBuilder.swift
//

import Foundation

public struct XMRWalletBuilder {
    
    // MARK: - Properties (private)
    
    private var language: String
    private var name: String
    private var password: String
    private var mode: Mode?
    
    
    // MARK: - Life Cycles
    
    init(name: String, password: String) {
        self.language = "English"
        self.name = name
        self.password = password
    }
    
    public func fromScratch() -> XMRWalletBuilder {
        var builder = self
        builder.mode = .fromScratch
        return builder
    }
    
    public func fromSeed(_ seed: Seed) -> XMRWalletBuilder {
        var builder = self
        builder.mode = .fromSeed(seed: seed)
        return builder
    }
    
    public func fromKeys(_ keys: Keys) -> XMRWalletBuilder {
        var builder = self
        builder.mode = .fromKeys(keys: keys)
        return builder
    }
    
    public func isValidatePassword() -> Bool {
        return MoneroWalletWrapper.verifyPassword(password, path: pathWithFileName() + ".keys")
    }
    
    public func openExisting() -> XMRWallet? {
        if let result = openExistingWallet() {
            return XMRWallet(walletWrapper: result)
        }
        return nil
    }
    
    public func generate() -> XMRWallet? {
        var wrapper: MoneroWalletWrapper?
        if let mode = self.mode {
            switch mode {
            case .openExisting:
                wrapper = self.openExistingWallet()
            case .fromScratch:
                wrapper = self.createWalletFromScratch()
            case .fromSeed(let seed):
                wrapper = self.recoverWalletFromSeed(seed)
            case .fromKeys(let keys):
                wrapper = self.recoverWalletFromKeys(keys: keys)
            }
        }
        guard let result = wrapper else { return nil }
        return XMRWallet(walletWrapper: result)
    }
    
    
    // MARK: - Methods (private)
    
    private func createWalletFromScratch() -> MoneroWalletWrapper? {
        return MoneroWalletWrapper.generate(withPath: pathWithFileName(), password: password, language: language)
    }
    
    private func recoverWalletFromSeed(_ seed: Seed) -> MoneroWalletWrapper? {
        return MoneroWalletWrapper.recover(withSeed: seed.sentence, path: pathWithFileName(), password: password)
    }
    
    private func recoverWalletFromKeys(keys:Keys) -> MoneroWalletWrapper? {
        return MoneroWalletWrapper.recoverFromKeys(withPath: pathWithFileName(), password: password, language: language, restoreHeight: keys.restoreHeight, address: keys.addressString, viewKey: keys.viewKeyString, spendKey: keys.spendKeyString)
    }
    
    private func openExistingWallet() -> MoneroWalletWrapper? {
        return MoneroWalletWrapper.openExisting(withPath: pathWithFileName(), password: password)
    }
    
    private func pathWithFileName() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + self.name
        return pathWithFileName
    }
}

extension XMRWalletBuilder {
    private enum Mode {
        case fromScratch
        case fromSeed(seed: Seed)
        case fromKeys(keys: Keys)
        case openExisting
    }
}
