//
//  SubAddressViewHeader.swift
//  Wookey
//
//  Created by jowsing on 2019/5/14.
//  Copyright © 2019 Wookey. All rights reserved.
//

import UIKit

class SubAddressViewCell: BaseTableViewCell {
    
    // MARK: - Properties (Lazy)
    
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
        labelLabel,
        addressLabel,
        copyBtn,
        optionImageView,
        ])
    }
    
    override func frameLayout() {
        labelLabel.updateFrame(CGRect(x: 25, y: 18, width: width - 80, height: labelLabel.font.lineHeight))
        addressLabel.updateFrame(CGRect(x: 25, y: labelLabel.maxY + 11, width: 220, height: addressLabel.font.lineHeight))
        copyBtn.updateFrame(CGRect(x: addressLabel.maxX, y: addressLabel.midY - 15, width: 30, height: 30))
        optionImageView.updateFrame(CGRect(x: width - 40, y: height * 0.5 - 10, width: 20, height: 20))
    }
    
    override func configure(with row: TableViewRow) {
        guard let model: SubAddressFrame = row.serializeModel() else { return }
        labelLabel.text = model.label
        addressLabel.text = model.address
        optionImageView.image = model.optionIcon
    }
    
}
