//
//  SubAddressViewController.swift
//  Wookey
//
//  Created by jowsing on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewController: BaseTableViewController {
    
    // MARK: - Properties (Public)
    
    override var rowHeight: CGFloat { return 83 }
    
    
    // MARK: - Properties (Private)
    
    private let viewModel: SubAddressViewModel
    
    
    // MARK: - Properties (Lazy)
    
    private lazy var tipsBanner = {
        TopMessageBanner(messages: [
            LocalizedString(key: "wallet.subAddress.tips1", comment: ""),
            LocalizedString(key: "wallet.subAddress.tips2", comment: ""),
        ])
    }()
    
    
    // MARK: - Life Cycles
    
    required init(viewModel: SubAddressViewModel) {
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
            navigationItem.title = LocalizedString(key: "wallet.subAddress.title", comment: "")
            view.addSubview(tipsBanner)
            tableView.register(cellType: SubAddressViewCell.self)
        }
        
        do /// Layout
        {
            tipsBanner.snp.makeConstraints { (make) in
                make.top.equalTo(44+UIApplication.shared.statusBarFrame.height)
                make.left.right.equalToSuperview()
            }
            tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(tipsBanner.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do /// Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "navigation_item_add"), style: .plain, target: self, action: #selector(self.addAction))
            
            onDidSelectRow { [unowned self] (row, _) in
                guard let indexPath = row.indexPath else { return }
                self.viewModel.didSelected(indexPath: indexPath)
            }
        }
        
        do /// ViewModel ->
        {
            viewModel.dataSourceState.observe(self) { (data, _Self) in
                _Self.dataSource = data
                _Self.tableView.reloadData()
            }
            
            viewModel.configureData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11, *) {
            
        } else {
            tableView.contentInset.top = 0
        }
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func addAction() {
        definesPresentationContext = true
        navigationController?.present(viewModel.toAdd(), animated: false, completion: nil)
    }

}
