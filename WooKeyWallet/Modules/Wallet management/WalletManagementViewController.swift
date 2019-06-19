//
//  WalletManagementViewController.swift


import UIKit


class WalletManagementViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var viewModel: WalletManagementViewModel = {
        return WalletManagementViewModel()
    }()
    
    private lazy var bottomBar: UIVisualEffectView = {
        let bottomBar = UIVisualEffectView(effect: UIBlurEffect.init(style: .light))
        bottomBar.contentView.backgroundColor = UIColor.init(white: 0.95, alpha: 0.7)
        bottomBar.layer.shadowColor = AppTheme.Color.tabBarShadow.cgColor
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        bottomBar.layer.shadowRadius = 3
        bottomBar.layer.shadowOpacity = 0.3
        bottomBar.alpha = 9.1
        return bottomBar
    }()
    
    private lazy var tokenVC = {
        TokenWalletsViewController.init(viewModel: viewModel, wallets: [])
    }()
    
    private lazy var recoveryBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "wallet.add.import", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_blue)
    }()
    
    private lazy var createBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "wallet.add.create", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_green)
    }()
    
    
    // MARK: - Life Cycles

    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "wallet.management.title", comment: "")
            view.backgroundColor = AppTheme.Color.tableView_bg
        }
        
        do /// Subviews
        {
            // bottom bar
            let line = UIView()
            line.backgroundColor = AppTheme.Color.cell_line
            bottomBar.contentView.addSubViews([
            recoveryBtn,
            createBtn,
            ])
            recoveryBtn.layer.cornerRadius = 19
            recoveryBtn.titleLabel?.font = AppTheme.Font.text_normal
            createBtn.layer.cornerRadius = 19
            recoveryBtn.titleLabel?.font = AppTheme.Font.text_normal
            recoveryBtn.snp.makeConstraints { (make) in
                make.left.equalTo(16)
                make.height.equalTo(38)
                make.top.equalTo(10)
            }
            createBtn.snp.makeConstraints { (make) in
                make.left.equalTo(recoveryBtn.snp.right).offset(15)
                make.top.equalTo(10)
                make.width.height.equalTo(recoveryBtn)
                make.right.equalTo(-16)
            }
            
            view.addSubViews([
            tokenVC.view,
            bottomBar,
            ])
            
            addChild(tokenVC)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        /// Actions
        recoveryBtn.addTarget(self, action: #selector(self.recoveryBtnAction), for: .touchUpInside)
        createBtn.addTarget(self, action: #selector(self.createBtnAction), for: .touchUpInside)
        
        /// ViewModel -> Load Data
        WalletService.shared.walletActiveState.observe(self) { (walletId, strongSelf) in
            strongSelf.loadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomBar_H: CGFloat
        if #available(iOS 11, *) {
            bottomBar_H = 58 + view.safeAreaInsets.bottom
        } else {
            bottomBar_H = 58
        }
        bottomBar.frame = CGRect(x: 0, y: view.height - bottomBar_H, width: view.width, height: bottomBar_H)
        tokenVC.view.frame = view.bounds
    }
    
    
    // MARK: - Methods (Private)
    
    private func toCreateWallet(_ model: WalletCreate) {
        let viewModel = CreateWalletViewModel(create: model)
        let vc = CreateWalletViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func recoveryBtnAction() {
        var create = WalletCreate()
        create.mode = .recovery
        toCreateWallet(create)
    }
    
    @objc private func createBtnAction() {
        var create = WalletCreate()
        create.mode = .new
        toCreateWallet(create)
    }
    
    // MARK: - Methods (Public)
    
    public func loadData() {
        let wallets = WalletService.shared.getWallets().map({ TokenWallet($0) })
        tokenVC.wallets = wallets
        tokenVC.loadData()
    }

}
