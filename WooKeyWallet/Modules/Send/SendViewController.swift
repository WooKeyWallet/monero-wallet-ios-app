//
//  SendViewController.swift


import UIKit

class SendViewController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let viewModel: SendViewModel
    

    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var header: SendViewHeader = {
        return SendViewHeader()
    }()
    
    private lazy var detailView: SendDetailView = {
        return SendDetailView()
    }()
    
    // MARK: - Life Cycles
    
    required init(asset: Assets, wallet: WalletProtocol) {
        self.viewModel = SendViewModel.init(asset: asset, wallet: wallet)
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
            scrollView.backgroundColor = AppTheme.Color.page_common
            view.addSubview(scrollView)

            let separatorView = UIView()
            separatorView.backgroundColor = AppTheme.Color.tableView_bg
            
            scrollView.contentView.addSubViews([
            header,
            separatorView,
            detailView,
            ])
            
            header.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            separatorView.snp.makeConstraints { (make) in
                make.top.equalTo(header.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(10)
            }
            detailView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(separatorView.snp.bottom)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_item_scan"), style: .plain, target: self, action: #selector(self.scanAction))
            
            detailView.toAddressField.tag = 19_1
            detailView.toAddressField.delegate = self
            detailView.amountField.tag = 19_2
            detailView.amountField.delegate = self
            detailView.paymentIdField.tag = 19_3
            detailView.paymentIdField.delegate = self
            
            detailView.sendBtn.addTarget(self, action: #selector(self.sendAction), for: .touchUpInside)
            detailView.addressSelectBtn.addTarget(self, action: #selector(self.addressSelectAction), for: .touchUpInside)
            detailView.allinBtn.addTarget(self, action: #selector(self.allinAction), for: .touchUpInside)
            detailView.paymentIdSwitch.addTarget(self, action: #selector(self.generatePaymentIdAction), for: .touchUpInside)
        }
        
        do /// ViewModel ->
        {
            viewModel.configureHeader(header)
            
            viewModel.addressState.observe(detailView.toAddressField) { (text, field) in
                field.text = text
            }
            viewModel.amountState.observe(detailView.amountField) { (text, field) in
                field.text = text
            }
            viewModel.paymentIdState.observe(detailView.paymentIdField) { (text, field) in
                field.text = text
            }
            viewModel.paymentIdLenState.observe(detailView.paymentIdLimitTip) { (text, label) in
                label.text = text
            }
            viewModel.sendState.observe(self) { (enable, strongSelf) in
                strongSelf.detailView.sendBtn.isEnabled = enable
                if enable {
                    strongSelf.scrollView.resizeContentLayout()
                }
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func scanAction() {
        navigationController?.pushViewController(viewModel.toScan(), animated: true)
    }
    
    @objc private func sendAction() {
        viewModel.createTransaction { [unowned self] in
            self.navigationController?.pushViewController(self.viewModel.toConfirm(), animated: true)
        }
    }
    
    @objc private func addressSelectAction() {
        let vc = viewModel.toSelectAddress()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func allinAction() {
        viewModel.allin()
    }
    
    @objc private func generatePaymentIdAction() {
        viewModel.generatePaymentId()
    }

}


// MARK: - TextView Delegate

extension SendViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 19_1:
            viewModel.inputAddress(textView.text)
        case 19_2:
            viewModel.inputAmount(textView.text)
        case 19_3:
            viewModel.inputPaymentId(textView.text)
        default:
            break
        }
    }
}
