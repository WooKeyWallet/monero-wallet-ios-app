//
//  TokenWalletDetailViewModel.swift


import UIKit

class TokenWalletDetailViewModel: NSObject {
    
    // MARK: - Properties (Private)
    
    private let tokenWallet: TokenWallet
    
    
    // MARK: - Properties (Lazy)
    
    lazy var reloadDataState = { Postable<[TableViewSection]>() }()
    
    
    // MARK: - Life Cycle

    required init(tokenWallet: TokenWallet) {
        self.tokenWallet = tokenWallet
        super.init()
    }
    
    func postData() {
        DispatchQueue.global().async {
            /// header
            let headerData = TokenWalletDetail.init(token: self.tokenWallet.token, assets: self.tokenWallet.amount, address: self.tokenWallet.address)
            var row_0_0 = TableViewRow.init(headerData, cellType: TokenWalletDeailHeaderCell.self, rowHeight: 146)
            row_0_0.actionHandler = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.copyAddress()
                }
            }
            var section0 = TableViewSection.init([row_0_0])
            section0.headerHeight = 0.01
            section0.footerHeight = 10
            
            /// dataSource
            let row_1_0 = TableViewRow.init((LocalizedString(key: "wallet.detail.name", comment: ""), self.tokenWallet.label), cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_1_1 = TableViewRow.init((LocalizedString(key: "wallet.detail.pwd.tips", comment: ""), ""), cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_1_1.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.showPasswordTips()
                }
            }
            var section1 = TableViewSection.init([row_1_0, row_1_1])
            section1.headerHeight = 0.01
            section1.footerHeight = 10
            
            
            var row_2_0 = TableViewRow.init((LocalizedString(key: "wallet.detail.import.seed", comment: ""), ""), cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_2_1 = TableViewRow.init((LocalizedString(key: "wallet.detail.import.keys", comment: ""), ""), cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_2_0.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toExportSeed()
                }
            }
            row_2_1.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toExportKeys()
                }
            }
            var section2 = TableViewSection.init([row_2_0, row_2_1])
            section2.headerHeight = 0.01
            section2.footerHeight = 10
            DispatchQueue.main.async {
                self.reloadDataState.newState([section0, section1, section2])
            }
        }
    }
    
    
    // MARK: - Methods (Public)
    
    public func getNavigationTitle() -> String {
        return tokenWallet.label
    }
    
    
    // MARK: - Methods (Private)
    
    private func copyAddress() {
        UIPasteboard.general.string = tokenWallet.address
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    private func showPasswordTips() {
        let alert = WKAlertController.init()
        alert.alertTitle = LocalizedString(key: "pwdTips", comment: "")
        alert.message = tokenWallet.pwdTips
        alert.msgAlignment = .center
        AppManager.default.rootViewController?.definesPresentationContext = true
        AppManager.default.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    private func toExportSeed() {
        LoginViewController.show(walletName: tokenWallet.label) { [unowned self] (pwd) in
            guard let pwd = pwd else { return }
            let vc = ExportWalletSeedViewController.init(walletName: self.tokenWallet.label, password: pwd)
            AppManager.default.rootViewController?.pushViewController(vc, animated: true)
        }
    }
    
    private func toExportKeys() {
        LoginViewController.show(walletName: tokenWallet.label) { [unowned self] (pwd) in
            guard let pwd = pwd else { return }
            let vc = ExportWalletKeysViewController.init(walletName: self.tokenWallet.label, password: pwd)
            AppManager.default.rootViewController?.pushViewController(vc, animated: true)
        }
    }
}
