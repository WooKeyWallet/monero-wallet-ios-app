//
//  AddressBookAddController.swift


import UIKit

class AddressBookAddController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let address = Address()
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var labelField: WKFloatingLabelTextField = {
        let field = WKFloatingLabelTextField.createTextField()
        field.placeholder = LocalizedString(key: "label", comment: "")
        field.title = LocalizedString(key: "label", comment: "")
        return field
    }()
    
    private lazy var tokenField: WKFloatingLabelTextField = {
        let field = WKFloatingLabelTextField.createTextField()
        field.placeholder = LocalizedString(key: "token", comment: "")
        field.title = LocalizedString(key: "token", comment: "")
        return field
    }()
    
    private lazy var selectionView: CoinTypeSelectionView = {
        return CoinTypeSelectionView()
    }()
    
    private lazy var confirmBtn: UIButton = {
        return UIButton.createCommon([UIButton.TitleAttributes.init(LocalizedString(key: "confirm", comment: ""), titleColor: AppTheme.Color.button_title, state: .normal)], backgroundColor: AppTheme.Color.main_blue)
    }()
    

    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "address.add.title", comment: "")
        }
        
        do /// Subviews
        {
            view.addSubViews([
            labelField,
            tokenField,
            selectionView,
            confirmBtn,
            ])
            
            labelField.snp.makeConstraints { (make) in
                make.top.equalTo(25+44+UIApplication.shared.statusBarFrame.height)
                make.left.equalTo(25)
                make.right.equalTo(-25)
            }
            tokenField.snp.makeConstraints { (make) in
                make.top.equalTo(labelField.snp.bottom).offset(16)
                make.left.equalTo(25)
                make.right.equalTo(-25)
            }
            selectionView.snp.makeConstraints { (make) in
                make.top.equalTo(tokenField.snp.bottom).offset(13)
                make.left.equalTo(25)
                make.right.equalTo(-25)
                make.height.equalTo(40)
            }
            confirmBtn.snp.makeConstraints { (make) in
                make.top.equalTo(selectionView.snp.bottom).offset(40)
                make.left.equalTo(25)
                make.right.equalTo(-25)
                make.height.equalTo(50)
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_item_scan"), style: .plain, target: self, action: #selector(self.scanAction))
            labelField.addTarget(self, action: #selector(self.labelInputAction(_:)), for: .editingChanged)
            tokenField.addTarget(self, action: #selector(self.tokenInputAction(_:)), for: .editingChanged)
//            selectionView.addTapGestureRecognizer(target: self, selector: #selector(self.coinSelectAction))
            confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        }
        
        do /// Models ->
        {
            confirmBtn.isEnabled = false
            let token = Token.xmr
            selectionView.configure(token)
            address.symbol = token.rawValue
        }
    }
    
    
    // MARK: - Methods (Action)

    @objc private func scanAction() {
        let vc = QRCodeScanViewController.init()
        vc.resultHandler = {
            [unowned self] (list, scanVC) in
            if let str = list.first?.strScanned {
                self.address.address = str
                self.tokenField.text = str
                self.confirmBtn.isEnabled = self.address.insertValid
                scanVC.navigationController?.popViewController(animated: true)
            } else {
                HUD.showError(LocalizedString(key: "not_recognized", comment: ""))
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func labelInputAction(_ sender: UITextField) {
        self.address.notes = sender.text ?? ""
        self.confirmBtn.isEnabled = self.address.insertValid
    }
    
    @objc private func tokenInputAction(_ sender: UITextField) {
        self.address.address = sender.text ?? ""
        self.confirmBtn.isEnabled = self.address.insertValid
    }
    
    @objc private func coinSelectAction() {
        
    }
    
    @objc private func confirmAction() {
        guard WalletService.validAddress(address.address, symbol: address.symbol) else {
            HUD.showError(LocalizedString(key: "address.validate.fail", comment: ""))
            return
        }
        DispatchQueue.global().async {
            var success = true
            if let db_address = DBService.shared.getAddressList(Address.Properties.address.is(self.address.address))?.first {
                if !DBService.shared.update(on: [Address.Properties.notes], with: self.address, condition: Address.Properties.id.is(db_address.id)) {
                    success = false
                }
            } else {
                if !DBService.shared.insertAddress(self.address) {
                    success = false
                }
            }
            DispatchQueue.main.async {
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    HUD.showError(LocalizedString(key: "add_fail", comment: ""))
                }
            }
        }
    }
}
