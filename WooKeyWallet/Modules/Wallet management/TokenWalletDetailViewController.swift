//
//  TokenWalletDetailViewController.swift


import UIKit

class TokenWalletDetailViewController: BDTableViewController {
    
    // MARK: - Properties (Public)
    
    override var style: UITableView.Style { return .grouped }
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: TokenWalletDetailViewModel
    
    
    // MARK: - Properties (Lazy)


    // MARK: - Life Cycle
    
    required init(viewModel: TokenWalletDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Views
        {
            tableView.register(cellType: TokenWalletDetailViewCell.self)
            tableView.register(cellType: TokenWalletDeailHeaderCell.self)
            tableView.register(cellType: TokenWalletDeleteCell.self)
            tableView.separatorInset.left = 25
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            
        }
        
        do /// ViewModel ->
        {
            navigationItem.title = viewModel.getNavigationTitle()
            viewModel.reloadDataState.observe(self) { (data, _Self) in
                _Self.dataSource = data
                _Self.tableView.reloadData()
            }
            viewModel.postData()
        }
    }

}
