//
//  LocalAuthViewModel.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

struct LocalAuthGesturePassword: GesturePasswordManager {
    
    let walletName: String
    let configResult: (Result<GesturePwdViewController.ConfigType, GesturePwdViewController.ConfigError>) -> Void
    
    init(_ walletName: String, configResult: @escaping (Result<GesturePwdViewController.ConfigType, GesturePwdViewController.ConfigError>) -> Void) {
        self.walletName = walletName
        self.configResult = configResult
    }
    
    func currentPassword() -> String {
        return KeyChain.string(forKey: walletName + "_ges") ?? ""
    }
    
    func updatePassword(_ password: String) {
        _ = KeyChain.set(string: password, forKey: walletName + "_ges")
    }
    
}

class LocalAuthViewModel: NSObject {
    
    // MARK: - Properties (public lazy)
    
    public lazy var dataSource = { Postable<[TableViewSection]>() }()
    public lazy var pushViewController = { Postable<UIViewController>() }()
    public lazy var presentViewController = { Postable<UIViewController>() }()
    

    // MARK: - Properties (private)
    
    private let walletName: String
    private let password: String
    private let storage: WalletDefaults
    
    
    // MARK: - Life Cycles
    
    init(walletName: String, password: String) {
        self.walletName = walletName
        self.password = RSA(encrypt: password).string
        self.storage = WalletDefaults(wallet: walletName)
        super.init()
    }
    
    func configure() {
        reloadData()
    }
    
    private func reloadData() {
        var sectionList = [TableViewSection]()
        defer {
            self.dataSource.newState(sectionList)
        }
        
        func addSection(_ block: () -> TableViewSection?) {
            guard let section = block() else { return }
            sectionList.append(section)
        }
        
        addSection { // section 0
            /// options
            var optionsRow = TableViewRow(self.storage.localAuthOptions, cellType: LocalAuthOptionsViewCell.self, rowHeight: 337)
            optionsRow.actionHandler = { [unowned self] (sender) in
                guard let options = sender as? [LocalAuthOptions] else { return }
                let oldOptions = self.storage.localAuthOptions
                self.storage.localAuthOptions = options
                if options.isEmpty {
                    self.storage.hasFaceOrTouchID = false
                    self.storage.hasGesturePassword = false
                    _=KeyChain.remove(forKey: self.walletName)
                    _=KeyChain.remove(forKey: self.walletName + "_ges")
                    self.alertPwdClosingTips(nil)
                }
                if (oldOptions.count * options.count == 0) && (oldOptions.count + options.count > 0) {
                    self.reloadData()
                }
            }
            var section = TableViewSection([optionsRow])
            section.headerHeight = 0.01
            section.footerHeight = 0.01
            return section
        }
        
        guard self.storage.localAuthOptions.count > 0 else { return }
        
        addSection { // section 1
            /// 面容 & 指纹
            var faceRow = TableViewRow((LocalizedString(key: "localAuth.biometry", comment: ""), self.storage.hasFaceOrTouchID), cellType: LocalAuthSwitchCell.self, rowHeight: 50)
            faceRow.actionHandler = {
                [unowned self] (sender) in
                guard let btn = sender as? UISwitch else { return }
                if self.storage.hasFaceOrTouchID {
                    self.alertPwdClosingTips { [unowned self] in
                        self.storage.hasFaceOrTouchID = !KeyChain.remove(forKey: self.walletName)
                        btn.setOn(self.storage.hasFaceOrTouchID, animated: true)
                    }
                } else {
                    guard !self.storage.hasGesturePassword else {
                        btn.setOn(self.storage.hasFaceOrTouchID, animated: true)
                        self.alertOnly1PwdStyleTips()
                        return
                    }
                    self.alertSecurityTips { [unowned self] in
                        LocalAuth.default.evaluatePolicy(LocalizedString(key: "localAuth.verify", comment: "")) { (result) in
                            switch result {
                            case .success:
                                self.storage.hasFaceOrTouchID = KeyChain.set(string: self.password, forKey: self.walletName)
                                if self.storage.hasFaceOrTouchID {
                                    HUD.showSuccess(LocalizedString(key: "setup.success", comment: ""))
                                }
                            case .failure(let error):
                                switch error {
                                case .passcodeNotSet:
                                    HUD.showError(LocalizedString(key: "passcodeNotSet", comment: ""))
                                case .biometryNotAvailable:
                                    HUD.showError(LocalizedString(key: "biometryNotAvailable", comment: ""))
                                case .biometryNotEnrolled:
                                    HUD.showError(LocalizedString(key: "biometryNotEnrolled", comment: ""))
                                case .biometryLockout:
                                    HUD.showError(LocalizedString(key: "biometryLockout", comment: ""))
                                default: break
                                }
                            }
                            btn.setOn(self.storage.hasFaceOrTouchID, animated: true)
                        }
                    }
                }
            }
            var section = TableViewSection([faceRow])
            section.headerTitle = LocalizedString(key: "localAuth.style", comment: "")
            section.headerHeight = 40
            section.footerHeight = 0.01
            return section
        }

        addSection {
            /// 手势
            var gestureRow = TableViewRow((LocalizedString(key: "localAuth.gesture", comment: ""), self.storage.hasGesturePassword), cellType: LocalAuthSwitchCell.self, rowHeight: 50)
            gestureRow.actionHandler = {
                [unowned self] (sender) in
                guard let btn = sender as? UISwitch else { return }
                if self.storage.hasGesturePassword {
                    self.alertPwdClosingTips { [unowned self] in
                        self.storage.hasGesturePassword = !KeyChain.remove(forKey: self.walletName) && !KeyChain.remove(forKey: self.walletName + "_ges")
                        btn.setOn(self.storage.hasGesturePassword, animated: true)
                    }
                } else {
                    guard !self.storage.hasFaceOrTouchID else {
                        btn.setOn(self.storage.hasGesturePassword, animated: true)
                        self.alertOnly1PwdStyleTips()
                        return
                    }
                    self.alertSecurityTips { [unowned self] in
                        self.toGesturePwdConfig(.setup)
                    }
                    btn.setOn(self.storage.hasGesturePassword, animated: true)
                }
            }
            var section = TableViewSection([gestureRow])
            if self.storage.hasGesturePassword {
                var setGesRow = TableViewRow(WKTableViewCell.Model(title: LocalizedString(key: "localAuth.gesture.modify", comment: ""), detail: nil), cellType: WKTableViewCell.self, rowHeight: 50)
                setGesRow.didSelectedAction = {
                    [unowned self] (_) in
                    self.toGesturePwdConfig(.modify)
                }
                section.rows.append(setGesRow)
            }
            section.headerHeight = 10
            section.footerHeight = 0.01
            return section
        }
    }
    
    private func alertSecurityTips(_ confirm: (() -> Void)?) {
        let alert = WKAlertController()
        alert.alertTitle = LocalizedString(key: "localAuth.security.title", comment: "")
        alert.message = LocalizedString(key: "localAuth.security.tips", comment: "")
        alert.msgAlignment = .left
        alert.confirmActionHandler = confirm
        presentViewController.newState(alert)
    }
    
    private func alertPwdClosingTips(_ confirm: (() -> Void)?) {
        let alert = WKAlertController()
        alert.alertTitle = LocalizedString(key: "tips", comment: "")
        alert.message = LocalizedString(key: "localAuth.pwdClosing.tips", comment: "")
        alert.msgAlignment = .center
        alert.confirmActionHandler = confirm
        presentViewController.newState(alert)
    }
    
    private func alertOnly1PwdStyleTips() {
        let alert = WKAlertController()
        alert.alertTitle = LocalizedString(key: "tips", comment: "")
        alert.message = LocalizedString(key: "localAuth.pwdOnly.tips", comment: "")
        alert.msgAlignment = .center
        presentViewController.newState(alert)
    }
    
    private func toGesturePwdConfig(_ type: GesturePwdViewController.ConfigType) {
        let passwordManager = LocalAuthGesturePassword(walletName) { [unowned self] (result) in
            switch result {
            case .success(let type):
                HUD.showSuccess(LocalizedString(key: "setup.success", comment: ""))
                if type == .setup {                    
                    self.storage.hasGesturePassword = KeyChain.set(string: self.password, forKey: self.walletName)
                    self.reloadData()
                }
            case .failure: break
            }
        }
        let vc = GesturePwdViewController(type: type, passwordManager: passwordManager)
        pushViewController.newState(vc)
    }
    
    func toHelp() {
        alertSecurityTips(nil)
    }
}
