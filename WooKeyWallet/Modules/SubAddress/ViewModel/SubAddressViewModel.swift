//
//  SubAddressViewModel.swift
//  Wookey
//
//  Created by WookeyWallet on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewModel: NSObject {
    
    // MARK: - Properties (private)
    
    private let wallet: XMRWallet
    
    private let deallocClosure: ((XMRWallet) -> Void)?
    
    private var list = [SubAddress]()
    
    private var needSave = false {
        didSet {
            guard needSave, !oldValue else {
                return
            }
            wallet.saveOnTerminate()
        }
    }
    
    
    // MARK: - Properties (private lazy)
    
    public lazy var dataSourceState = { Postable<[TableViewSection]>() }()
    
    public lazy var modalState = { Postable<UIViewController>() }()
    
    
    // MARK: - Life Cycles
    
    required init(wallet: XMRWallet, deallocClosure: ((XMRWallet) -> Void)? = nil) {
        self.wallet = wallet
        self.deallocClosure = deallocClosure
        super.init()
    }
    
    deinit {
        self.deallocClosure?(wallet)
    }
    
    func configureData() {
        DispatchQueue.global().async {
            self.list = self.wallet.getAllSubAddress()
            let publicAddress = self.wallet.publicAddress
            let rowList: [TableViewRow] = self.list.map({
                let model = $0
                var row = TableViewRow(SubAddressFrame(model: model, address: publicAddress), cellType: SubAddressViewCell.self, rowHeight: 83)
                row.actionHandler = { [unowned self] sender in
                    self.toEdit(model)
                }
                return row
            })
            DispatchQueue.main.async {
                self.dataSourceState.newState([TableViewSection(rowList)])
            }
        }
    }
    
    func toAdd() -> UIViewController {
        let vc = AddSubAddressController(viewModel: self)
        return vc
    }
    
    func toEdit(_ model: SubAddress) {
        let vc = AddSubAddressController(viewModel: self)
        vc.subAddress = model
        modalState.newState(vc)
    }
    
    func addSubAddress(label: String) {
        HUD.showHUD()
        wallet.addSubAddress(label) { (success) in
            DispatchQueue.main.async {
                HUD.hideHUD()
                if success {
                    self.needSave = true
                    self.configureData()
                } else {
                    HUD.showError(LocalizedString(key: "add_fail", comment: ""))
                }
            }
        }
    }
    
    func setSubAddress(label: String, row: Int) {
        HUD.showHUD()
        wallet.setSubAddress(label, rowId: row) { (success) in
            DispatchQueue.main.async {
                HUD.hideHUD()
                if success {
                    self.needSave = true
                    if let subAddress = WalletDefaults.shared.subAddress[self.wallet.publicAddress],
                        subAddress.address == self.list[row].address {
                        var model = subAddress; model.label = label
                        WalletDefaults.shared.subAddress[self.wallet.publicAddress] = model
                    }
                    self.configureData()
                } else {
                    HUD.showError(LocalizedString(key: "add_fail", comment: ""))
                }
            }
        }
    }
    
    func didSelected(indexPath: IndexPath) {
        guard indexPath.row < list.count else {
            return
        }
        let model = list[indexPath.row]
        WalletDefaults.shared.subAddress[wallet.publicAddress] = model
        configureData()
    }
    
    
}
