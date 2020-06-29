//
//  AddressBooksController.swift


import UIKit

class AddressBooksController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 66 }
    
    var didSelected: ((String) -> Void)?
    
    
    // MARK: - Properties (private)
    
    private var addressList = [Address]()
    
    
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
            self.addressList = DBService.shared.getAddressList() ?? []
            let rowList: [TableViewRow] = self.addressList.map({ address in
                var row = TableViewRow.init(AddressBook(address), cellType: AddressBookViewCell.self)
                row.actionHandler = { [unowned self] value in
                    guard let action = value as? TableViewRowAction else { return }
                    switch action {
                    case .delete(let indexPath): // 删除
                        self.deleteConfirm(address, indexPath: indexPath)
                    case .edit: // 编辑
                        self.toEdit(address)
                    default: break
                    }
                }
                return row
            })
            let section = TableViewSection(rowList)
            self.dataSource = [section]
            if rowList.count == 0 {
                state = .withoutData
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableViewPlaceholder.state = state
            }
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func addAction() {
        navigationController?.pushViewController(AddressBookAddController(), animated: true)
    }
    
    private func toEdit(_ address: Address) {
        let textFiled = UITextField()
        textFiled.placeholder = LocalizedString(key: "addressbook.edit.placeholder", comment: "")
        let alert = AlertInputViewController(title: LocalizedString(key: "addressbook.edit.title", comment: ""), textField: textFiled)
        alert.addAction(WKAlertAction(title: LocalizedString(key: "save", comment: ""), style: .confirm) { [unowned self] (action) in
            address.notes = textFiled.text ?? ""
            if DBService.shared.update(on: [Address.Properties.notes], with: address, condition: Address.Properties.id.is(address.id)) {
                self.loadData()
            }
        })
        alert.addAction(WKAlertAction(title: nil, style: .cancel))
        DispatchQueue.main.async {
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    private func deleteConfirm(_ address: Address, indexPath: IndexPath) {
        if DBService.shared.deleteAddress(Address.Properties.address.is(address.address)) {
            addressList.remove(at: indexPath.row)
            dataSource[indexPath.section].rows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

