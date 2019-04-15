//
//  CreateWalletViewController.swift


import UIKit


class CreateWalletViewController: BaseViewController {
    
    // MARK: - Properties (Public)
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: CreateWalletViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var contentView: CreateWalletView = {
        let contentV = CreateWalletView()
        contentV.backgroundColor = AppTheme.Color.page_common
        return contentV
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: CreateWalletViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = contentView
    }
    
    override func configureUI() {
        super.configureUI()
        do {
            self.navigationItem.title = viewModel.navigationTitle()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            contentView.walletNameField.addTarget(self, action: #selector(self.walletNameEidtingAction(_:)), for: .editingChanged)
            contentView.walletPwdField.addTarget(self, action: #selector(self.walletPwdEidtingAction(_:)), for: .editingChanged)
            contentView.walletPwdConfirmField.addTarget(self, action: #selector(self.walletPwdConfirmEidtingAction(_:)), for: .editingChanged)
            contentView.walletPwdMSGField.addTarget(self, action: #selector(self.walletPwdTipsEidtingAction(_:)), for: .editingChanged)
            contentView.pwdSecureTextEntryBtn.addTarget(self, action: #selector(self.pwdSecureTextEntryAction(_:)), for: .touchDown)
            contentView.agreementBtn.addTarget(self, action: #selector(self.agreementAction(_:)), for: .touchDown)
            contentView.serviceBookBtn.handleCustomTap(for: contentView.serviceBookBtn.enabledTypes[0]) { [unowned self] (_) in
                self.navigationController?.pushViewController(self.viewModel.toServiceBook(), animated: true)
            }
            contentView.nextBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        }
        
        do /// ViewModel -> View
        {
            viewModel.nameTextState.observe(contentView.walletNameField) { (text, field) in
                field.text = text
            }
            
            viewModel.nameErrorState.observe(contentView.walletNameField) { (msg, field) in
                field.errorMessage = msg
            }
            viewModel.pwdErrorState.observe(contentView.walletPwdField) { (msg, field) in
                field.errorMessage = msg
                if msg != nil {
                    field.resignFirstResponder()
                    field.text = ""
                }
            }
            viewModel.pwdConfirmErrorState.observe(contentView.walletPwdConfirmField) { (msg, field) in
                field.errorMessage = msg
                if msg != nil {
                    field.resignFirstResponder()
                    field.text = ""
                }
            }
            
            viewModel.pwdSecureTextEntryState.observe(contentView) { (bool, _contentView) in
                _contentView.pwdSecureTextEntryBtn.isSelected = bool
                _contentView.walletPwdField.isSecureTextEntry = bool
                _contentView.walletPwdConfirmField.isSecureTextEntry = bool
            }
            viewModel.agreementState.observe(contentView.agreementBtn) { (bool, btn) in
                btn.isSelected = bool
            }
            
            viewModel.nextState.observe(contentView.nextBtn) { (bool, btn) in
                btn.isEnabled = bool
            }
            
            viewModel.pwdRankState.observe(contentView.pwdRankView) { (level, rankView) in
                rankView.level = level
            }
            
            viewModel.pushState.observe(self) { (vc, strongSelf) in
                guard let vc = vc else { return }
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func walletNameEidtingAction(_ sender: UITextField) {
        viewModel.nameFieldInput(sender.text!)
    }
    
    @objc private func walletPwdEidtingAction(_ sender: UITextField) {
        viewModel.pwdFieldInput(sender.text!)
    }
    
    @objc private func walletPwdConfirmEidtingAction(_ sender: UITextField) {
        viewModel.pwdConfirmFieldInput(sender.text!)
    }
    
    @objc private func walletPwdTipsEidtingAction(_ sender: UITextField) {
        viewModel.pwdTipsFieldInput(sender.text!)
    }
    
    @objc private func pwdSecureTextEntryAction(_ sender: UIButton) {
        viewModel.pwdSecureTextEntryClick()
    }
    
    @objc private func agreementAction(_ sender: UIButton) {
        viewModel.agreementClick()
    }
    
    @objc private func confirmAction() {
        viewModel.nextClick()
    }

}
