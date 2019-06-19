//
//  ReceiveViewController.swift


import UIKit

class ReceiveViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: ReceiveViewModel
    

    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var receiveView: ReceiveView = {
        return ReceiveView()
    }()
    
    
    // MARK: - Life Cycles
    
    init(token: TokenWallet, wallet: WalletProtocol) {
        self.viewModel = ReceiveViewModel.init(token: token, wallet: wallet)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = viewModel.navigationTitle
        }
        
        do /// Subviews
        {
            scrollView.backgroundColor = AppTheme.Color.tableView_bg
            view.addSubview(scrollView)
            
            receiveView.addressTipLabel.text = viewModel.receiveTips
            scrollView.contentView.addSubview(receiveView)
            
            receiveView.snp.makeConstraints { (make) in
                make.top.equalTo(18)
                make.left.equalTo(25)
                make.right.equalTo(-25)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            // Btns
            receiveView.addTapGestureRecognizer(target: self, selector: #selector(self.unfoldAction(_:)))
            receiveView.showHideAddrBtn.addTarget(self, action: #selector(self.showHideAddressAction), for: .touchUpInside)
            receiveView.subAddressBtn.addTarget(self, action: #selector(self.toSubAddressAction), for: .touchUpInside)
            receiveView.copyAddressBtn.addTarget(self, action: #selector(self.copyAddressAction), for: .touchUpInside)
            receiveView.newPayIdBtn.addTarget(self, action: #selector(self.generatePaymentIdAction), for: .touchUpInside)
            receiveView.copyPayIdBtn.addTarget(self, action: #selector(self.copyPaymentIdAction), for: .touchUpInside)
            receiveView.addressVSPayIdCopyBtn.addTarget(self, action: #selector(self.copyIntegartAddrAction), for: .touchUpInside)
            
            // TextViews
            receiveView.paymentIdField.tag = 19_2
            receiveView.paymentIdField.delegate = self
        }
        
        do /// ViewModel ->
        {
            receiveView.amountLabel.text = viewModel.receiveTitle
            viewModel.addressState.observe(self) { (text, _Self) in
                _Self.receiveView.addressView.text = text
                _Self.scrollView.resizeContentLayout()
            }
            viewModel.qrcodeState.observe(receiveView.qrcodeView) { (qrcode, imageView) in
                imageView.image = qrcode
            }
            viewModel.paymentIdState.observe(self) { (text, _Self) in
                _Self.receiveView.paymentIdField.text = text
                _Self.scrollView.resizeContentLayout()
            }
            viewModel.intergartedAddressState.observe(self) { (text, _Self) in
                _Self.receiveView.integartedAddressField.text = text
                _Self.scrollView.resizeContentLayout()
            }
            viewModel.paymentIdCountState.observe(receiveView.payIdLimitLab) { (text, label) in
                label.text = text
            }
            viewModel.configure()
        }
                
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func unfoldAction(_ sender: UIGestureRecognizer) {
        let touchPoint = sender.location(in: receiveView)
        guard receiveView.unfoldBtn.frame.contains(touchPoint) else { return }
        receiveView.unfoldBtn.isSelected = !receiveView.unfoldBtn.isSelected
        receiveView.setUnFold(receiveView.unfoldBtn.isSelected)
        scrollView.resizeContentLayout()
    }
    
    @objc private func showHideAddressAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        receiveView.addressView.isSecureTextEntry = sender.isSelected
        viewModel.showHideAddress(sender.isSelected)
    }
    
    @objc private func copyAddressAction() {
        viewModel.copyAddress()
    }
    
    @objc private func generatePaymentIdAction() {
        viewModel.generatePaymentId()
    }
    
    @objc private func copyPaymentIdAction() {
        viewModel.copyPaymentId()
    }
    
    @objc private func copyIntegartAddrAction() {
        viewModel.copyIntegartedAddress()
    }
    
    @objc private func toSubAddressAction() {
        navigationController?.pushViewController(viewModel.toSubAddress(), animated: true)
    }

}


// MARK: - TextView Delegate

extension ReceiveViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 19_2:
            viewModel.inputPaymentId(textView.text)
        default:
            break
        }
        scrollView.resizeContentLayout()
    }
}
