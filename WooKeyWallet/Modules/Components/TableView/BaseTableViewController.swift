//
//  BaseTableViewController.swift


import UIKit

class BaseTableViewController: BaseViewController {
    
    typealias DidSelectRowAt = (TableViewRow, BaseTableViewController) -> Void
    
    
    // MARK: - Properties (Public)
    
    public var dataSource = [TableViewSection]()
    public var style: UITableView.Style { return UITableView.Style.plain }
    public var rowHeight: CGFloat { return 50 }
    
    
    // MARK: - Properties (Private)
    
    private var didSelectRowHandler: DidSelectRowAt?
    
    
    // MARK: - Properties (Lazy)
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.backgroundColor = AppTheme.Color.tableView_bg
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = rowHeight
        tableView.separatorColor = AppTheme.Color.cell_line
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    public lazy var tableViewPlaceholder: TableViewPlaceholder = {
        let placeholder = TableViewPlaceholder.init(frame: view.bounds)
        placeholder.setImage(UIImage(named: "transrecord_placeholder_withoudata"), for: .withoutData)
        placeholder.setDescription(LocalizedString(key: "no_data", comment: "暂无记录"), for: .withoutData)
        placeholder.setImage(UIImage(named: "tableview_placeholder_error"), for: .networkError)
        placeholder.setDescription(LocalizedString(key: "no_net", comment: "网络错误"), for: .networkError)
        placeholder.backgroundColor = tableView.backgroundColor
        return placeholder
    }()
    
    
    // MARK: - Properties (Closure)
    
    
    
    // MARK: - Life Cycles
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        self.view.backgroundColor = tableView.backgroundColor
        self.view.addSubview(self.tableView)
        self.tableView.addSubview(self.tableViewPlaceholder)
        
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            //            if #available(iOS 11.0, *) {
            //                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            //            } else {
            //                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            //            }
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if tableView.contentInset.bottom < self.view.safeAreaInsets.bottom + 20 {
                tableView.contentInset.bottom = self.view.safeAreaInsets.bottom + 20
            }
        } else {
            if tableView.contentInset.bottom < self.bottomLayoutGuide.length + 20 {
                tableView.contentInset.bottom = self.bottomLayoutGuide.length + 20
            }
        }
        tableViewPlaceholder.updateFrame(tableView.bounds)
        tableViewPlaceholder.backgroundColor = tableView.backgroundColor
    }
    
    
    // MARK: - Methods (Public)
    
    public func onDidSelectRow(_ handler: DidSelectRowAt?) {
        self.didSelectRowHandler = handler
    }
    
    public func disableAdjustContentInsert() {
        self.modalPresentationCapturesStatusBarAppearance = false
        self.edgesForExtendedLayout = .all
        if #available(iOS 11, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    // MARK: - Methods (Private)
    
    
    
    // MARK: - Methods (Action)
    
    // MARK: - Methods (Notification)
    
    // MARK: - Methods (KVO)

}


// MARK: - UITableViewDataSource

extension BaseTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        let cell: BaseTableViewCell = tableView.dequeueReusableCell(for: indexPath, cellType: row.cellType)
        cell.configure(with: row)
        return cell
    }
}


// MARK: - UITableViewDelegate

extension BaseTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource[section].headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSource[section].footerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row = dataSource[indexPath.section].rows[indexPath.row]
        row.indexPath = indexPath
        row.didSelectedAction?(indexPath.row)
        didSelectRowHandler?(row, self)
    }
}
