//
//  MarketsViewController.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/9.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class MarketsViewController: BaseTableViewController {
    
    // MARK: - Properties (override)
    
    override var rowHeight: CGFloat { 70 }
    
    
    // MARK: - Properties (private lazy)
    
    private lazy var viewModel: MarketsViewModel = {
        MarketsViewModel()
    }()
    
    private lazy var topLegalLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.button_title
        label.textAlignment = .center
        label.font = AppTheme.Font.text_normal.medium()
        label.backgroundColor = AppTheme.Color.main_green
        return label
    }()
    
    private lazy var loadingView: WKActivityIndicatorView = {
        let loadingView = WKActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .systemGray
        loadingView.backgroundColor = .clear
        return loadingView
    }()
    
    
    // MARK: - Life Cycles

    override func configureUI() {
        super.configureUI()

        do // Views
        {
            navigationItem.title = LocalizedString(key: "settings.markets", comment: "")
            
            view.addSubview(topLegalLabel)
            
            tableView.register(cellType: MarketsViewCell.self)
            tableViewPlaceholder.setImage(UIImage.bundleImage("no_address_placeholder"), for: .withoutData)
            tableViewPlaceholder.setDescription(LocalizedString(key: "address.empty", comment: ""), for: .withoutData)
            tableView.addSubview(loadingView)
        }
        
        do // Layouts
        {
            topLegalLabel.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                } else {
                    make.top.equalTo(topLayoutGuide.snp.bottom)
                }
                make.left.right.equalTo(0)
                make.height.equalTo(44)
            }
            
            tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(topLegalLabel.snp.bottom)
                make.left.right.bottom.equalTo(0)
            }
            
            loadingView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            
            disableAdjustContentInsert()
        }
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        do // Actions
        {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "legal_switch_icon"), style: .plain, target: self, action: #selector(switchLegalAction))
        }
        
        do // ViewModels
        {
            viewModel.xmrPriceTextState.observe(topLegalLabel) { (text, label) in
                label.text = text
            }
            
            viewModel.dataSourceState.observe(self) { (data, SELF) in
                SELF.dataSource = data
                SELF.tableView.reloadData()
            }
            
            viewModel.modalState.observe(self) { (viewController, SELF) in
                SELF.present(viewController, animated: true, completion: nil)
            }
            
            viewModel.loadingState.observe(self) { (loading, SELF) in
                SELF.loadingView.isLoading = loading
            }
            
            viewModel.configure()
        }
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func switchLegalAction() {
        viewModel.toSwicthLegal()
    }

}
