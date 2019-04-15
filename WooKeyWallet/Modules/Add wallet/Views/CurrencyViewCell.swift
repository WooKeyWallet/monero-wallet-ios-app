//
//  CurrencyViewCell.swift


import UIKit

class CurrencyViewCell: BaseTableViewCell {
    
    // MARK: - Life Cycles

    override func initCell() {
        super.initCell()
        detailLabel.textColor = AppTheme.Color.text_light
        detailLabel.font = AppTheme.Font.text_smaller
        detailLabel.textAlignment = .left
        contentView.addSubViews([
            iconView,
            nameLabel,
            detailLabel,
            rightArrow,
        ])
    }
    
    override func frameLayout() {
        let mid_Y = height * 0.5
        iconView.updateFrame(CGRect(x: 25, y: mid_Y - 17.5, width: 35, height: 35))
        rightArrow.updateFrame(CGRect(x: width - 33, y: mid_Y - 6.5, width: 8, height: 13))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 10, y: iconView.y, width: rightArrow.x - iconView.maxX - 10, height: nameLabel.font.lineHeight))
        detailLabel.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY, width: nameLabel.width, height: detailLabel.font.lineHeight))
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: Currency = row.serializeModel() else { return }
        iconView.image = model.icon
        nameLabel.text = model.name
        detailLabel.text = model.fullName
    }

}
