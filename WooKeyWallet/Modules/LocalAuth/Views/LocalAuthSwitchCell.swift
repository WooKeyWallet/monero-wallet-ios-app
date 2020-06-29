//
//  LocalAuthSwitchCell.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/6/10.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class LocalAuthSwitchCell: BaseTableViewCell {
    
    private var actionHandler: ((Any) -> Void)?
    
    // MARK: - Properties (private lazy)
    
    private lazy var switchBtn: UISwitch = {
        let btn = UISwitch()
        btn.onTintColor = AppTheme.Color.main_green
        return btn
    }()
    

    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        nameLabel.font = AppTheme.Font.text_normal
        contentView.addSubViews([
            nameLabel,
            switchBtn,
        ])
        switchBtn.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let (name, isOn): (String, Bool) = row.serializeModel() else { return }
        nameLabel.text = name
        switchBtn.isOn = isOn
    }
    
    override func frameLayout() {
        nameLabel.updateFrame(CGRect(x: 25, y: 0, width: width - 100, height: height))
        switchBtn.updateFrame(CGRect(x: nameLabel.maxX, y: height * 0.5 - 15, width: 50, height: 30))
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func switchAction(_ sender: UISwitch) {
        actionHandler?(sender)
    }

}
