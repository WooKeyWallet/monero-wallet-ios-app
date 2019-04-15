//
//  SeedViewController.swift


import UIKit

class SeedViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    override var interactivePopGestureEnable: Bool { return false }
    
    
    // MARK: - Properties (Private)
    
    private let wallet: WalletProtocol
    private let create: WalletCreate
    
    
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
    
    private lazy var confirmBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "words.list.confirm", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        return btn
    }()
    
    // MARK: - Life Cycles
    
    required init(wallet: WalletProtocol, create: WalletCreate) {
        self.wallet = wallet
        self.create = create
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "wallet.add.create", comment: "")
            
            scrollView.frame = view.bounds
            view.addSubview(scrollView)
        }
        
        do /// Subviews
        {
            scrollView.contentView.addSubViews([
            topMessageBG,
            wordListView,
            confirmBtn,
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
                confirmBtn.snp.makeConstraints { (make) in
                    make.left.right.equalTo(wordListView)
                    make.top.equalTo(wordListView.snp.bottom).offset(37)
                    make.height.equalTo(50)
                }
                scrollView.resizeContentLayout()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_copy"), style: .plain, target: self, action: #selector(self.copyAction))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        do /// Models ->
        {
            if let seed = wallet.seed {
                seedString = seed.sentence
                wordListView.configure(seed.words)
                scrollView.resizeContentLayout()
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = SeedAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false, completion: nil)
    }
    
    deinit {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction() {
        UIPasteboard.general.string = seedString
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    @objc private func confirmAction() {
        guard let seed = wallet.seed else { return }
        let vc = SeedVerifyViewController.init(seed: seed)
        navigationController?.pushViewController(vc, animated: true)
    }

}
