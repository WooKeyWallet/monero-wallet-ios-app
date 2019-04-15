//
//  NodeSettingsViewCell.swift


import UIKit

class NodeSettingsViewCell: BaseTableViewCell {
    
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
        iconView.updateFrame(CGRect(x: 25, y: mid_Y - 14.5, width: 29, height: 29))
        rightArrow.updateFrame(CGRect(x: width - 33, y: mid_Y - 6.5, width: 8, height: 13))
        let nameW = (nameLabel.text ?? "").boundingRect(with: CGSize.bounding, font: nameLabel.font).width
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 9, y: mid_Y - 15, width: nameW, height: 30))
        detailLabel.updateFrame(CGRect(x: nameLabel.maxX + 10, y: nameLabel.y, width: rightArrow.x - nameLabel.maxX - 16, height: nameLabel.height))
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: TokenNodeModel = row.serializeModel() else { return }
        iconView.image = model.tokenImage
        nameLabel.text = model.tokenName
        detailLabel.text = model.tokenNode
        frameLayout()
    }
}
