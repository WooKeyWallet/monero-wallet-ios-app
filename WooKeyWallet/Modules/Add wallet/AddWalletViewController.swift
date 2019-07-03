//
//  AddWalletViewController.swift


import UIKit

class AddWalletViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    override var hideNavigationBar: Bool { return true }
    
    
    // MARK: - Properties (Private)
    
    private lazy var createWalletBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "wallet.add.create", comment: "创建钱包"), titleColor: AppTheme.Color.button_title, state: .normal)
        ], backgroundColor: AppTheme.Color.main_green)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    private lazy var importWalletBtn: UIButton = {
        let btn = UIButton.createCommon([
            UIButton.TitleAttributes.init(LocalizedString(key: "wallet.add.import", comment: "导入钱包"), titleColor: AppTheme.Color.button_title, state: .normal)
            ], backgroundColor: AppTheme.Color.main_blue)
        btn.layer.cornerRadius = 25
        return btn
    }()
    
    
    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        /// initSubViews
        let initSubViews = {
            () -> (topIcon: UIImageView, tipLabel: UILabel) in
            // topIcon
            let topIcon = UIImageView()
            topIcon.image = UIImage.bundleImage("about_icon")
            self.view.addSubview(topIcon)
            
            // tipLabel
            let tipLabel = UILabel()
            tipLabel.textAlignment = .center
            tipLabel.textColor = AppTheme.Color.text_gray
            tipLabel.font = AppTheme.Font.text_smaller
            tipLabel.text = LocalizedString(key: "wallet.add.tips", comment: "")
            tipLabel.numberOfLines = 0
            self.view.addSubview(tipLabel)
            
            // bottom
            self.view.addSubview(self.createWalletBtn)
            self.view.addSubview(self.importWalletBtn)
            
            return (topIcon, tipLabel)
        }()
        
        
        do /// autoLayout
        {
            // scale to iPhone6s Height
            let scaleToHeight = view.height / 667
            initSubViews.topIcon.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(123 * scaleToHeight + UIApplication.shared.statusBarFrame.height)
                make.size.equalTo(CGSize(width: 181, height: 135))
            }
            initSubViews.tipLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(28)
                make.right.equalToSuperview().offset(-28)
                make.bottom.equalTo(createWalletBtn.snp.top).offset(-70)
            }
            createWalletBtn.snp.makeConstraints { (make) in
                make.left.right.equalTo(initSubViews.tipLabel)
                make.height.equalTo(50)
                make.bottom.equalTo(importWalletBtn.snp.top).offset(-15)
            }
            importWalletBtn.snp.makeConstraints { (make) in
                make.left.right.height.equalTo(createWalletBtn)
                if #available(iOS 11, *) {
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-45)
                } else {
                    make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom).offset(-45)
                }
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        createWalletBtn.addTarget(self, action: #selector(self.createWalletAction), for: .touchUpInside)
        importWalletBtn.addTarget(self, action: #selector(self.importWalletAction), for: .touchUpInside)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func createWalletAction() {
        var model = WalletCreate()
        model.mode = .new
        toCreateWallet(model)
    }
    
    @objc private func importWalletAction() {
        var model = WalletCreate()
        model.mode = .recovery
        toCreateWallet(model)
    }
    
    private func toCreateWallet(_ model: WalletCreate) {
        let viewModel = CreateWalletViewModel(create: model)
        let vc = CreateWalletViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

}
