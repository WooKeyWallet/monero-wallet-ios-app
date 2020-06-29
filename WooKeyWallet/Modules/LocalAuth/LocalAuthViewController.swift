//
//  LocalAuthViewController.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/18.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class LocalAuthViewController: BDTableViewController {
    
    // MARK: - Properties (override)
    
    override var style: UITableView.Style { .grouped }
    
    
    // MARK: - Properties (private)
    
    private let viewModel: LocalAuthViewModel
    

    // MARK: - Life Cycles
    
    required init(viewModel: LocalAuthViewModel) {
        self.viewModel = viewModel
        super.init()
        self.definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        super.configureUI()
        
        do // Views
        {
            navigationItem.title = LocalizedString(key: "wallet.detail.localAuth", comment: "")
            tableView.register(cellType: LocalAuthOptionsViewCell.self)
            tableView.register(cellType: LocalAuthSwitchCell.self)
            tableView.register(cellType: WKTableViewCell.self)
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do // Actions ->
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "help_icon"), style: .plain, target: self, action: #selector(toHelp))
        }
        
        do // ViewModels ->
        {
            viewModel.dataSource.observe(self) { (data, SELF) in
                SELF.dataSource = data
                SELF.tableView.reloadData()
            }
            
            viewModel.pushViewController.observe(self) { (viewController, SELF) in
                SELF.navigationController?.pushViewController(viewController, animated: true)
            }
            
            viewModel.presentViewController.observe(self) { (viewController, SELF) in
                SELF.present(viewController, animated: false, completion: nil)
            }
            
            viewModel.configure()
        }
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func toHelp() {
        viewModel.toHelp()
    }
    
}
