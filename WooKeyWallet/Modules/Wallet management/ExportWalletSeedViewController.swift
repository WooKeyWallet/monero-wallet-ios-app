//
//  ExportWalletSeedViewController.swift


import UIKit

class ExportWalletSeedViewController: BaseViewController {
    
    
    // MARK: - Properties (Private)
    
    private var seedString: String? {
        didSet {
            let text = seedString ?? ""
            navigationItem.rightBarButtonItem?.isEnabled = text.count > 0
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var topMessageBG: TopMessageBanner = {
        return TopMessageBanner.init(messages: [
            LocalizedString(key: "words.create.tip1", comment: ""),
            LocalizedString(key: "words.create.tip2", comment: "")
            ])
    }()
    
    private lazy var wordListView: WordListView = {
        let v = WordListView.init()
        v.title = LocalizedString(key: "words.list.title", comment: "")
        return v
    }()

    
    // MARK: - Life Cycles
    
    required init(walletName: String, password: String) {
        super.init()
        self.openWallet(walletName, pwd: password)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "wallet.detail.import.seed", comment: "")
            scrollView.frame = view.bounds
            view.addSubview(scrollView)
        }
        
        do /// Subviews
        {
            scrollView.contentView.addSubViews([
                topMessageBG,
                wordListView,
                ])
            
            do // auto layout
            {
                topMessageBG.snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                }
                wordListView.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(25)
                    make.right.equalToSuperview().offset(-25)
                    make.top.equalTo(topMessageBG.snp.bottom).offset(25)
                }

                scrollView.resizeContentLayout()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_copy"), style: .plain, target: self, action: #selector(self.copyAction))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = SeedAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
    
    
    // MARK: - Methods (Private)
    
    private func openWallet(_ name: String, pwd: String) {
        HUD.showHUD()
        WalletService.shared.safeOperation {
            do {
                let wallet = try WalletService.shared.loginWallet(name, password: pwd)
                if let seed = wallet.seed {
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        self.seedString = seed.sentence
                        self.wordListView.configure(seed.words)
                        self.scrollView.resizeContentLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        HUD.hideHUD()
                        HUD.showError(LocalizedString(key: "wallet.detail.import.error", comment: ""))
                    }
                }
                wallet.lock()
            } catch {
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    HUD.showError(LocalizedString(key: "wallet.detail.import.error", comment: ""))
                }
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction() {
        UIPasteboard.general.string = seedString
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }

}
