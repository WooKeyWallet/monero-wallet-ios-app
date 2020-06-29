//
//  SubAddressViewHeader.swift
//  Wookey
//
//  Created by WookeyWallet on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewCell: BaseTableViewCell {
    
    // MARK: - Properties (private)
    
    private var actionHandler: ((Any) -> Void)?
    
    
    // MARK: - Properties (private lazy)
    
    private lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "edit_icon_s"), for: .normal)
        return btn
    }()
    
    private lazy var labelLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.text_normal
        label.textColor = AppTheme.Color.text_dark
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.text_small
        label.textColor = AppTheme.Color.text_light
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "receive_copy"), for: .normal)
        return btn
    }()
    
    private lazy var optionImageView: UIImageView = {
        return UIImageView()
    }()
    
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        addSubViews([
        editBtn,
        labelLabel,
        addressLabel,
        copyBtn,
        optionImageView,
        ])
        editBtn.addTarget(self, action: #selector(toEditAction), for: .touchUpInside)
        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
    }
    
    override func frameLayout() {
        editBtn.updateFrame(CGRect(x: 20, y: 13, width: 28, height: 28))
        labelLabel.updateFrame(CGRect(x: 48, y: 18, width: width - 80, height: 18))
        addressLabel.updateFrame(CGRect(x: 25, y: labelLabel.maxY + 11, width: 220, height: addressLabel.font.lineHeight))
        copyBtn.updateFrame(CGRect(x: addressLabel.maxX, y: addressLabel.midY - 15, width: 30, height: 30))
        optionImageView.updateFrame(CGRect(x: width - 40, y: height * 0.5 - 10, width: 20, height: 20))
    }
    
    override func configure(with row: TableViewRow) {
        self.actionHandler = row.actionHandler
        guard let model: SubAddressFrame = row.serializeModel() else { return }
        labelLabel.text = model.label
        addressLabel.text = model.address
        optionImageView.image = model.optionIcon
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func copyAction() {
        guard let text = addressLabel.text else { return }
        UIPasteboard.general.string = text
        HUD.showSuccess(LocalizedString(key: "copy_success", comment: ""))
    }
    
    @objc private func toEditAction() {
        actionHandler?(editBtn)
    }
    
}
