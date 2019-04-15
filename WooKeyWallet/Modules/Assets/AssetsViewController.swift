//
//  AssetsViewController.swift


import UIKit

class AssetsViewController: BaseTableViewController {
    
    // MARK: - Properties (Private)
    
    private var wallet: Wallet?
    private var assetsList = [Assets]()
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var titleLabel = { return UILabel() }()
    private lazy var header = { AssetsViewHeader() }()
    private lazy var footer = { AssetsListView(width: view.width) }()
    
    
    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Subviews
        {
            navigationItem.titleView = {
                (lab: UILabel) -> UILabel in
                lab.textColor = AppTheme.Color.navigationTitle
                lab.textAlignment = .center
                lab.font = AppTheme.Font.navigationTitle
                return lab
            }(titleLabel)
            tableView.tableHeaderView = header
            tableView.tableFooterView = footer
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "assets_token_manage"), style: .plain, target: self, action: #selector(self.leftBarButtonAction))
            navigationItem.rightBarButtonItem = {
                () -> UIBarButtonItem in
                let btn = UIButton(frame: .zero)
                btn.setImage(UIImage(named: "assets_eye_show"), for: .normal)
                btn.setImage(UIImage(named: "assets_eye_hidden"), for: .selected)
                btn.sizeToFit()
                btn.addTarget(self, action: #selector(self.rightBarButtonAction(_:)), for: .touchUpInside)
                return UIBarButtonItem.init(customView: btn)
            }()
            
            header.copyBtn.addTarget(self, action: #selector(self.copyAction), for: .touchUpInside)
            
            footer.configureHandlers { [unowned self] (index) in
                guard let wallet = self.wallet else { return }
                LoginViewController.show(walletName: wallet.name, loginResult: { [unowned self] (pwd) in
                    guard let pwd = pwd else { return }
                    var assets = self.assetsList[index]
                    assets.wallet = TokenWallet.init(wallet)
                    self.navigationController?.pushViewController(AssetsTokenViewController.init(tokenAssets: assets, pwd: pwd), animated: true)
                })
            }
        }
        
        do /// Reload datas
        {
            WalletService.shared.walletActiveState.observe(self) { (walletId, strongSelf) in
                if let wallet = WalletService.shared.getActiveWallet() {
                    strongSelf.wallet = wallet
                    strongSelf.assetsList = WalletService.shared.getAssets(wallet.id)
                    strongSelf.titleLabel.text = wallet.symbol
                    strongSelf.titleLabel.sizeToFit()
                    strongSelf.header.configure(wallet)
                    strongSelf.footer.configure(strongSelf.assetsList)
                }
            }
            
            WalletService.shared.assetRefreshState.observe(self) { (signal, strongSelf) in
                guard let _ = signal, let wallet_id = strongSelf.wallet?.id else { return }
                strongSelf.assetsList = WalletService.shared.getAssets(wallet_id)
                strongSelf.footer.configure(strongSelf.assetsList)
            }
        }
    }
    
    
    
    // MARK: - Methods (Action)
    
    @objc private func leftBarButtonAction() {
        let vc = WalletManagementViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func rightBarButtonAction(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        footer.balanceSecureTextEntryState = btn.isSelected
    }
    
    @objc private func copyAction() {
        UIPasteboard.general.string = wallet?.address
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
}
