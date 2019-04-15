//
//  ExportWalletKeysViewController.swift


import UIKit

class ExportWalletKeysViewController: BaseViewController {

    // MARK: - Properties (Private)
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var topBar: UIView = {
        createTopBar()
    }()
    
    private lazy var publicViewKeyField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "publicViewKey", comment: "")
        field.placeholder = LocalizedString(key: "publicViewKey", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var secretViewKeyField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "secretViewKey", comment: "")
        field.placeholder = LocalizedString(key: "secretViewKey", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var publicSpendKeyField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "publicSpendKey", comment: "")
        field.placeholder = LocalizedString(key: "publicSpendKey", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var secretSpendKeyField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "secretSpendKey", comment: "")
        field.placeholder = LocalizedString(key: "secretSpendKey", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var addressField: JVFloatLabeledTextView = {
        let field = JVFloatLabeledTextView.createTextView()
        field.floatingLabel.text = LocalizedString(key: "address", comment: "")
        field.placeholder = LocalizedString(key: "address", comment: "")
        field.isEditable = false
        return field
    }()
    
    private lazy var lines = { [UIView(), UIView(), UIView(), UIView(), UIView()] }()
    
    private lazy var copyBtns = { [createCopyBtn(), createCopyBtn(), createCopyBtn(), createCopyBtn(), createCopyBtn()] }()
    
    
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
            navigationItem.title = LocalizedString(key: "wallet.detail.import.keys", comment: "")
            scrollView.frame = view.bounds
            view.addSubview(scrollView)
        }
        
        do /// Subviews
        {
            lines.forEach({ $0.backgroundColor = AppTheme.Color.cell_line })
            scrollView.contentView.addSubViews([
                topBar,
                publicViewKeyField,
                secretViewKeyField,
                publicSpendKeyField,
                secretSpendKeyField,
                addressField,
            ])
            scrollView.contentView.addSubViews(lines)
            scrollView.contentView.addSubViews(copyBtns)
            
            do // auto layout
            {
                topBar.snp.makeConstraints { (make) in
                    make.top.equalTo(0)
                    make.left.right.equalTo(0)
                    make.height.equalTo(42)
                }
                
                publicViewKeyField.snp.makeConstraints { (make) in
                    make.left.equalTo(25)
                    make.top.equalTo(topBar.snp.bottom).offset(25)
                }
                lines[0].snp.makeConstraints { (make) in
                    make.top.equalTo(publicViewKeyField.snp.bottom)
                    make.left.equalTo(25)
                    make.right.equalTo(-25)
                    make.height.equalTo(px(1))
                }
                copyBtns[0].snp.makeConstraints { (make) in
                    make.top.equalTo(publicViewKeyField).offset(22)
                    make.right.equalTo(-20)
                    make.left.equalTo(publicViewKeyField.snp.right).offset(10)
                    make.size.equalTo(25)
                }
                
                secretViewKeyField.snp.makeConstraints { (make) in
                    make.left.equalTo(25)
                    make.top.equalTo(publicViewKeyField.snp.bottom).offset(15)
                }
                lines[1].snp.makeConstraints { (make) in
                    make.top.equalTo(secretViewKeyField.snp.bottom)
                    make.left.equalTo(25)
                    make.right.equalTo(-25)
                    make.height.equalTo(px(1))
                }
                copyBtns[1].snp.makeConstraints { (make) in
                    make.top.equalTo(secretViewKeyField).offset(22)
                    make.right.equalTo(-20)
                    make.left.equalTo(secretViewKeyField.snp.right).offset(10)
                    make.size.equalTo(25)
                }
                
                publicSpendKeyField.snp.makeConstraints { (make) in
                    make.left.equalTo(25)
                    make.top.equalTo(secretViewKeyField.snp.bottom).offset(25)
                }
                lines[2].snp.makeConstraints { (make) in
                    make.top.equalTo(publicSpendKeyField.snp.bottom)
                    make.left.equalTo(25)
                    make.right.equalTo(-25)
                    make.height.equalTo(px(1))
                }
                copyBtns[2].snp.makeConstraints { (make) in
                    make.top.equalTo(publicSpendKeyField).offset(22)
                    make.right.equalTo(-20)
                    make.left.equalTo(publicSpendKeyField.snp.right).offset(10)
                    make.size.equalTo(25)
                }
                
                secretSpendKeyField.snp.makeConstraints { (make) in
                    make.left.equalTo(25)
                    make.top.equalTo(publicSpendKeyField.snp.bottom).offset(15)
                }
                lines[3].snp.makeConstraints { (make) in
                    make.top.equalTo(secretSpendKeyField.snp.bottom)
                    make.left.equalTo(25)
                    make.right.equalTo(-25)
                    make.height.equalTo(px(1))
                }
                copyBtns[3].snp.makeConstraints { (make) in
                    make.top.equalTo(secretSpendKeyField).offset(22)
                    make.right.equalTo(-20)
                    make.left.equalTo(secretSpendKeyField.snp.right).offset(10)
                    make.size.equalTo(25)
                }
                
                addressField.snp.makeConstraints { (make) in
                    make.left.equalTo(25)
                    make.top.equalTo(secretSpendKeyField.snp.bottom).offset(15)
                }
                lines[4].snp.makeConstraints { (make) in
                    make.top.equalTo(addressField.snp.bottom)
                    make.left.equalTo(25)
                    make.right.equalTo(-25)
                    make.height.equalTo(px(1))
                }
                copyBtns[4].snp.makeConstraints { (make) in
                    make.top.equalTo(addressField).offset(22)
                    make.right.equalTo(-20)
                    make.left.equalTo(addressField.snp.right).offset(10)
                    make.size.equalTo(25)
                }
                
                scrollView.resizeContentLayout()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        stride(from: 0, to: copyBtns.count, by: 1).forEach { (i) in
            let btn = copyBtns[i]
            btn.tag = i
            btn.addTarget(self, action: #selector(self.copyAction(sender:)), for: .touchUpInside)
        }
    }
    
    
    // MARK: - Methods (Private)
    
    private func createTopBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = AppTheme.Color.main_green_light
        let iconV = UIImageView(image: UIImage(named: "export.keys.icon"))
        let label = UILabel()
        label.text = LocalizedString(key: "wallet.detail.import.keys.tips", comment: "")
        label.textColor = AppTheme.Color.button_title
        label.font = AppTheme.Font.text_smaller
        label.numberOfLines = 0
        bar.addSubViews([iconV, label])
        iconV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(25)
            make.size.equalTo(20)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(iconV.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalTo(-25)
        }
        return bar
    }
    
    private func createCopyBtn() -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: "receive_copy"), for: .normal)
        return btn
    }
    
    private func openWallet(_ name: String, pwd: String) {
        HUD.showHUD()
        WalletService.shared.safeOperation {
            do {
                let wallet = try WalletService.shared.loginWallet(name, password: pwd)
                let (publicViewKey, publicSpendKey, secretViewKey, secretSpendKey, address) = (wallet.publicViewKey,
                                                                                               wallet.publicSpendKey,
                                                                                               wallet.secretViewKey,
                                                                                               wallet.secretSpendKey,
                                                                                               wallet.publicAddress)
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    self.publicViewKeyField.text = publicViewKey
                    self.publicSpendKeyField.text = publicSpendKey
                    self.secretViewKeyField.text = secretViewKey
                    self.secretSpendKeyField.text = secretSpendKey
                    self.addressField.text = address
                    self.scrollView.resizeContentLayout()
                }
                WalletService.shared.safeOperation({
                    wallet.lock()
                })
            } catch {
                DispatchQueue.main.async {
                    HUD.hideHUD()
                    HUD.showError(LocalizedString(key: "wallet.detail.import.error", comment: ""))
                }
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func copyAction(sender: UIButton) {
        var copy_text = ""
        switch sender.tag {
        case 0:
            copy_text = publicViewKeyField.text
        case 1:
            copy_text = secretViewKeyField.text
        case 2:
            copy_text = publicSpendKeyField.text
        case 3:
            copy_text = secretSpendKeyField.text
        case 4:
            copy_text = addressField.text
        default:
            break
        }
        guard copy_text != "" else {
            return
        }
        UIPasteboard.general.string = copy_text
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }

}
