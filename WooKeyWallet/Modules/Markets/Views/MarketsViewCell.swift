//
//  MarketsViewCell.swift
//  Wookey
//
//  Created by WookeyWallet on 2020/5/9.
//  Copyright © 2020 Wookey. All rights reserved.
//

import UIKit

class MarketsViewCell: BaseTableViewCell {
    
    private lazy var xmrAmountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    private lazy var legalAmountLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal.medium()
        label.textAlignment = .right
        return label
    }()
    
    private lazy var legalTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        label.textAlignment = .right
        return label
    }()

    override func initCell() {
        super.initCell()
        iconView.contentMode = .scaleAspectFit
        contentView.addSubViews([
            iconView,
            nameLabel,
            xmrAmountLabel,
            legalAmountLabel,
            legalTypeLabel,
        ])
    }
    
    override func frameLayout() {
        let (nameW, legalTypeW) = (nameLabel.sizeThatFits(.zero).width, legalTypeLabel.sizeThatFits(.zero).width)
        iconView.updateFrame(CGRect(x: 25, y: 15, width: 40, height: 40))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 5, y: iconView.y, width: nameW, height: 23))
        xmrAmountLabel.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY, width: width - legalTypeW - 95, height: 17))
        legalAmountLabel.updateFrame(CGRect(x: nameLabel.maxX, y: nameLabel.y, width: width - nameLabel.maxX - 25, height: 23))
        legalTypeLabel.updateFrame(CGRect(x: xmrAmountLabel.maxX, y: xmrAmountLabel.y, width: legalTypeW, height: 17))
    }
    
    override func configure(with row: TableViewRow) {
        guard let model: MarketsModel = row.serializeModel() else { return }
        iconView.image = model.icon
        nameLabel.text = model.coinText
        legalAmountLabel.text = model.amountText
        legalTypeLabel.text = model.legalText
        xmrAmountLabel.text = model.xmrPriceText
    }
}
