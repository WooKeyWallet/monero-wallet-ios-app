//
//  TransactionListController.swift


import UIKit

enum TransactionsType: Int { case all, `in`, out }

class TransactionListController: BaseTableViewController {

    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    // 滑动是否进入结束状态，转交父级滑动
    public lazy var isScrollEND = { return Observable<Bool>(true) }()
    
    
    // MARK: - Properties (Private)
    
    private let transactionType: TransactionsType
    
    
    // MARK: - Life Cycles
    
    required init(type: TransactionsType) {
        self.transactionType = type
        super.init()
        self.title = LocalizedString(key: "\(type)", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do/// Subviews
        {
            tableView.backgroundColor = AppTheme.Color.page_common
            tableView.register(cellType: TransactionListCell.self)
            tableView.separatorInset.left = 25
            tableViewPlaceholder.setImage(UIImage.bundleImage("transaction_no_data"), for: .withoutData)
            tableViewPlaceholder.setDescription(LocalizedString(key: "assets.records.nodata", comment: ""), for: .withoutData)
            
            tableViewPlaceholder.snp.remakeConstraints { (make) in
                make.top.equalTo(150)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 196, height: 139))
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    func reloadData() {
        tableViewPlaceholder.state = dataSource.count > 0 ? .none : .withoutData
        tableView.reloadData()
    }
    
    
    // MARK: - Methods (UIScrollViewDelegate)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrollEND.value else {
            scrollView.contentOffset = .zero
            return
        }
        if scrollView.contentOffset.y <= -20 {
            scrollView.contentOffset = .zero
            isScrollEND.value = true
        }
    }
    
}
