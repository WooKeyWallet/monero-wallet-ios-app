//
//  SubAddressViewModel.swift
//  Wookey
//
//  Created by jowsing on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewModel: NSObject {
    
    // MARK: - Properties
    
    private let wallet: WalletProtocol
    
    private let deallocClosure: ((WalletProtocol) -> Void)?
    
    public lazy var dataSourceState = { Postable<[TableViewSection]>() }()
    
    
    // MARK: - Life Cycles
    
    required init(wallet: WalletProtocol, deallocClosure: ((WalletProtocol) -> Void)? = nil) {
        self.wallet = wallet
        self.deallocClosure = deallocClosure
        super.init()
    }
    
    deinit {
        self.deallocClosure?(wallet)
    }
    
    func configureData() {
        DispatchQueue.global().async {
            let mainModel = SubAddress(rowId: -1, address: self.wallet.publicAddress, label: LocalizedString(key: "primaryAddress", comment: ""))
            var list = self.wallet.getAllSubAddress()
            if list.first?.address == mainModel.address {
                list[0] = mainModel
            } else {
                list.insert(mainModel, at: 0)
            }
            let rowList = list.map({
                TableViewRow(SubAddressFrame(model: $0, address: mainModel.address), cellType: SubAddressViewCell.self, rowHeight: 83)
            })
            DispatchQueue.main.async {
                self.dataSourceState.newState([TableViewSection(rowList)])
            }
        }
    }
    
    func toAdd() -> UIViewController {
        let vc = AddSubAddressController(viewModel: self)
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    func addSubAddress(label: String) {
        if self.wallet.addSubAddress(label) {
            configureData()
        } else {
            HUD.showError(LocalizedString(key: "add_fail", comment: ""))
        }
    }
    
    func didSelected(indexPath: IndexPath) {
        if indexPath.row == 0 {
            WalletDefaults.shared.subAddressIndexs[wallet.publicAddress] = nil
        } else {
            let list = wallet.getAllSubAddress()
            WalletDefaults.shared.subAddressIndexs[wallet.publicAddress] = list[indexPath.row].address
        }
        configureData()
    }
    
    
}
