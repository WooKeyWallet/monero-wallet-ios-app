//
//  CurrencyPickerViewController.swift


import UIKit

class CurrencyPickerViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 75 }
    override var style: UITableView.Style { return .grouped }
    
    public let create: WalletCreate
    
    
    // MARK: - Properties (Private)
    
    private var selectedHandler: ((Token) -> Void)?
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var tokenList = { return Array<Token>([.xmr]) }()
    
    
    // MARK: - Life Cycles
    
    convenience init(_ resultHandler: ((Token) -> Void)?) {
        self.init(WalletCreate())
        self.selectedHandler = resultHandler
    }
    
    required init(_ create: WalletCreate) {
        self.create = create
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        /// Self
        do{
            navigationItem.title = LocalizedString(key: "wallet.import.tokenSelect", comment: "币种选择")
        }
        
        /// tableView
        do{
            tableView.register(cellType: CurrencyViewCell.self)
            tableView.separatorInset.left = -100
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        /// loadTokens
        do{
            let loadTokens = {
                () -> [TableViewSection] in
                let sections: [TableViewSection] = self.tokenList.map({
                    var sec = TableViewSection.init([TableViewRow.init(Currency.init($0), cellType: CurrencyViewCell.self, rowHeight: self.rowHeight)])
                    sec.footerHeight = 10
                    sec.headerHeight = 0.1
                    return sec
                })
                return sections
            }()
            dataSource = loadTokens
            tableView.reloadData()
        }
        
        /// onDidSelectRow
        onDidSelectRow { [unowned self] (row, _) in
            guard let index = row.indexPath?.section else { return }
            let token = self.tokenList[index]
            if let handler = self.selectedHandler {
                handler(token)
                self.navigationController?.popViewController(animated: true)
                return
            }
            var create = self.create
            let vc = CreateWalletViewController.init(viewModel: CreateWalletViewModel.init(create: create))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
