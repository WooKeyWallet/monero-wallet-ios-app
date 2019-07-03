//
//  TransactionDetailViewController.swift


import UIKit

class TransactionDetailController: BaseViewController {
    
    // MARK: - Properties (Private)
    
    private let transaction: Transaction
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var scrollView: AutoLayoutScrollView = {
        return AutoLayoutScrollView()
    }()
    
    private lazy var detailView: TransactionDetailView = {
        return TransactionDetailView()
    }()
    
    
    // MARK: - Life Cycles
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = transaction.token + " " + LocalizedString(key: "transaction.detail.title", comment: "")
        }
        
        do /// Subviews
        {
            scrollView.backgroundColor = AppTheme.Color.tableView_bg
            view.addSubview(scrollView)
            
            scrollView.contentView.addSubViews([detailView])
            
            detailView.snp.makeConstraints { (make) in
                make.left.equalTo(23)
                make.right.equalTo(-23)
                make.top.equalTo(16)
            }
            
            scrollView.resizeContentLayout()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        detailView.configure(model: transaction)
        scrollView.resizeContentLayout()
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.transIdlongPressAction))
        detailView.blockInfoView.transactionIdLabel.addGestureRecognizer(longPress)
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func transIdlongPressAction() {
        UIPasteboard.general.string = transaction.hash
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
}
