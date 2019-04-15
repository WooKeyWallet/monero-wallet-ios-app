//
//  TokenNodeListController.swift


import UIKit

class TokenNodeListController: BaseTableViewController {

    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 62 }
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: TokenNodeListViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var moreNodeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(LocalizedString(key: "moreNodeAddress", comment: ""), for: .normal)
        btn.setTitleColor(AppTheme.Color.text_light, for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.titleLabel?.font = AppTheme.Font.text_small
        return btn
    }()
    
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: TokenNodeListViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do /// Subviews
        {
            tableView.backgroundColor = AppTheme.Color.page_common
            tableView.register(cellType: TokenNodeListCell.self)
            tableView.separatorInset.left = 25
            tableView.tableFooterView = {
                () -> UIView in
                let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 65))
                footer.addSubview(moreNodeBtn)
                moreNodeBtn.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                })
                let line = UIView(frame: CGRect(x: 25, y: 0, width: view.width - 25, height: px(1)))
                line.backgroundColor = AppTheme.Color.cell_line
                footer.addSubview(line)
                return footer
            }()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Model -> View
        {
            self.navigationItem.title = viewModel.getNavigationTitle()
            
            viewModel.dataSourceOb.observe(self) { (dataSource, strongsSelf) in
                strongsSelf.dataSource = dataSource
                strongsSelf.tableView.reloadData()
            }
            viewModel.reloadIndexPathState.observe(self) { (row, _Self) in
                guard let indexPath = row.indexPath,
                    indexPath.row < _Self.dataSource[0].rows.count else { return }
                _Self.dataSource[indexPath.section].rows[indexPath.row] = row
                _Self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            viewModel.loadData()
        }
        
        do /// Action
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "token.node.add"), style: .plain, target: self, action: #selector(self.addNodeAction))
            onDidSelectRow { [unowned self] (row, _) in
                guard let indexPath = row.indexPath else { return }
                self.viewModel.didSelect(indexPath)
            }
            moreNodeBtn.addTarget(self, action: #selector(self.moreNodeAction), for: .touchUpInside)
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func addNodeAction() {
        definesPresentationContext = true
        navigationController?.present(viewModel.toAddNodeViewController(), animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return viewModel.editActionsForRow(at: indexPath)
    }
    
    @objc private func moreNodeAction() {
        let web = WebViewController(WooKeyURL.moreNodes.url)
        navigationController?.pushViewController(web, animated: true)
    }
}
