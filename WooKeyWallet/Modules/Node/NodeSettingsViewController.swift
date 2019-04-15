//
//  NodeSettingsViewController.swift


import UIKit

class NodeSettingsViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var viewModel = { return NodeSettingsViewModel() }()
    
    
    // MARK: - Life Cycles
    
    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "settings.node", comment: "节点设置")
        }
        
        do /// Subviews
        {
            tableView.register(cellType: NodeSettingsViewCell.self)
            tableView.separatorInset.left = 25
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Load Data
        {
            
        }
        
        do /// Select Action
        {
            onDidSelectRow { [unowned self] (row, _) in
                guard let indexPath = row.indexPath else { return }
                self.navigationController?.pushViewController(self.viewModel.getNextViewController(indexPath), animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataSource = viewModel.getDataSource()
        self.tableView.reloadData()
    }
}
