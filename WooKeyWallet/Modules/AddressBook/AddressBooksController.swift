//
//  AddressBooksController.swift


import UIKit

class AddressBooksController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 66 }
    
    var didSelected: ((String) -> Void)?
    
    
    // MARK: - Life Cycles

    override func configureUI() {
        super.configureUI()
        
        do /// Self
        {
            navigationItem.title = LocalizedString(key: "address.title", comment: "")
        }
        
        do /// Subviews
        {
            tableView.register(cellType: AddressBookViewCell.self)
            tableView.separatorInset.left = 25
            tableViewPlaceholder.setImage(UIImage.bundleImage("no_address_placeholder"), for: .withoutData)
            tableViewPlaceholder.setDescription(LocalizedString(key: "address.empty", comment: ""), for: .withoutData)
            tableViewPlaceholder.setButtonTitle(LocalizedString(key: "address.add.title", comment: ""), for: .withoutData)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_item_add"), style: .plain, target: self, action: #selector(self.addAction))
        
        tableViewPlaceholder.bottomButton.addTarget(self, action: #selector(self.addAction), for: .touchUpInside)
        
        onDidSelectRow { [unowned self] (row, _) in
            guard let model: AddressBook = row.serializeModel(), let handler = self.didSelected else { return }
            handler(model.tokenAddress)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }
    
    private func loadData() {
        DispatchQueue.global().async {
            var state = TableViewPlaceholder.State.none
            if let list = DBService.shared.getAddressList() {
                let rowList = list.map({ TableViewRow.init(AddressBook.init($0), cellType: AddressBookViewCell.self) })
                let section = TableViewSection(rowList)
                self.dataSource = [section]
                if rowList.count == 0 {
                    state = .withoutData
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                state = .withoutData
            }
            DispatchQueue.main.async {
                self.tableViewPlaceholder.state = state
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func addAction() {
        navigationController?.pushViewController(AddressBookAddController(), animated: true)
    }

}
