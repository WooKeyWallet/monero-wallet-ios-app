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
    
    func configure() {
        WalletDefaults.shared.subAddressIndexState.observe(self) { (_, _Self) in
            _Self.postData()
        }
    }
    
    private func postData() {
        DispatchQueue.global().async {
            /// header
            let headerData = TokenWalletDetail.init(token: self.tokenWallet.token, assets: self.tokenWallet.amount, address: self.tokenWallet.address)
            var row_0_0 = TableViewRow.init(headerData, cellType: TokenWalletDeailHeaderCell.self, rowHeight: /*146*/110)
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
            let modelList: [[TokenWalletDetaillViewCellModel]] = [
                [],
                [
                    (title: LocalizedString(key: "wallet.detail.name", comment: ""), detail: self.tokenWallet.label, showArrow: false),
                    (title: LocalizedString(key: "wallet.subAddress.title", comment: ""), detail: WalletService.displayAddress(self.tokenWallet.address), showArrow: true),
                ],
                [
                    (title: LocalizedString(key: "wallet.detail.pwd.tips", comment: ""), detail: "", showArrow: true),
                    (title: LocalizedString(key: "wallet.detail.import.seed", comment: ""), detail: "", showArrow: true),
                    (title: LocalizedString(key: "wallet.detail.import.keys", comment: ""), detail: "", showArrow: true),
                ],
            ]
            let row_1_0 = TableViewRow.init(modelList[1][0], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_1_1 = TableViewRow.init(modelList[1][1], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_1_1.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toSubAddress()
                }
            }
            var section1 = TableViewSection.init([row_1_0, row_1_1])
            section1.headerHeight = 0.01
            section1.footerHeight = 10
            
            var row_2_0 = TableViewRow.init(modelList[2][0], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_2_1 = TableViewRow.init(modelList[2][1], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            var row_2_2 = TableViewRow.init(modelList[2][2], cellType: TokenWalletDetailViewCell.self, rowHeight: 52)
            row_2_0.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.showPasswordTips()
                }
            }
            row_2_1.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toExportSeed()
                }
            }
            row_2_2.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toExportKeys()
                }
            }
            var section2 = TableViewSection.init([row_2_0, row_2_1, row_2_2])
            section2.headerHeight = 0.01
            section2.footerHeight = 10
            
            var row_3_0 = TableViewRow.init(nil, cellType: TokenWalletDeleteCell.self, rowHeight: 52)
            row_3_0.didSelectedAction = {
                [unowned self] _ in
                DispatchQueue.main.async {
                    self.toDeleteWallet()
                }
            }
            var section3 = TableViewSection.init([row_3_0])
            section3.headerHeight = 0.01
            section3.footerHeight = 10
            DispatchQueue.main.async {
                self.reloadDataState.newState([section0, section1, section2, section3])
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
    
    private func toSubAddress() {
        LoginViewController.show(walletName: tokenWallet.label) {
        [unowned self] (pwd) in
            guard let pwd = pwd else { return }
            HUD.showHUD()
            WalletService.shared.safeOperation({
                do {
                    let wallet = try WalletService.shared.loginWallet(self.tokenWallet.label, password: pwd)
                    let viewModel = SubAddressViewModel(wallet: wallet, deallocClosure: { _wallet in
                        WalletService.shared.safeOperation({
                            _wallet.lock()
                        })
                    })
                    let vc = SubAddressViewController(viewModel: viewModel)
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        AppManager.default.rootViewController?.pushViewController(vc, animated: true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        HUD.showError(LocalizedString(key: "loadFail", comment: ""))
                    }
                }
            })
        }
        
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
    
    private func toDeleteWallet() {
        guard !tokenWallet.in_use else {
            HUD.showError(LocalizedString(key: "delete.wallet.onlineError", comment: ""))
            return
        }
        LoginViewController.show(walletName: tokenWallet.label) { [unowned self] (pwd) in
            guard let _ = pwd else { return }
            HUD.showHUD()
            WalletService.shared.safeOperation({
                guard WalletService.shared.removeWallet(self.tokenWallet.label) else {
                    DispatchQueue.main.async {
                        HUD.showError(LocalizedString(key: "delete.failure", comment: ""))
                    }
                    return
                }
                DispatchQueue.main.async {
                    WalletService.shared.walletActiveState.value = WalletService.shared.walletActiveState.value
                    HUD.showSuccess(LocalizedString(key: "delete.success", comment: ""))
                    AppManager.default.rootViewController?.popViewController(animated: true)
                }
            })
        }
    }
}
