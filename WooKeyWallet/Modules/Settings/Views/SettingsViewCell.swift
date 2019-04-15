//
//  SettingsViewCell.swift


import UIKit

class SettingsViewCell: BaseTableViewCell {
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        contentView.addSubViews([
            iconView,
            nameLabel,
            detailLabel,
            rightArrow,
        ])
    }
    
    override func frameLayout() {
        let mid_Y = height * 0.5
        iconView.updateFrame(CGRect(x: 25, y: mid_Y - 14, width: 28, height: 28))
        rightArrow.updateFrame(CGRect(x: width - 33, y: mid_Y - 6.5, width: 8, height: 13))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 11, y: mid_Y - 15, width: rightArrow.x - iconView.maxX - 25, height: 30))
        detailLabel.updateFrame(nameLabel.frame)
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: SettingsItem = row.serializeModel() else { return }
        iconView.image = model.icon
        nameLabel.text = model.name
        detailLabel.text = model.text
    }
}
