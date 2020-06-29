//
//  SendConfirmViewController.swift


import UIKit

class SendConfirmViewController: BaseViewController {

    // MARK: - Properties (Private)
    
    private let viewModel: SendViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var confirmView: SendConfirmView = {
        return SendConfirmView()
    }()
    
    // MARK: - Life Cycles
    
    required init(viewModel: SendViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "send.confirm.title", comment: "")
        }
        
        do /// Subviews
        {
            scrollView.backgroundColor = AppTheme.Color.page_common
            view.addSubview(scrollView)
            
            scrollView.contentView.addSubViews([
                confirmView,
            ])
            
            confirmView.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        /// Actions
        confirmView.confirmBtn.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        
        /// ViewModel ->
        viewModel.configureConfirm(confirmView)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func confirmAction() {
        LoginViewController.loginWithOptions(.sendXMR, walletName: viewModel.walletName) { [unowned self] (pwd) in
            guard let _ = pwd else { return }
            self.viewModel.commitTransaction()
        }
    }

}
