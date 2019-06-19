//
//  TokenWalletDetailViewCell.swift


import UIKit

class TokenWalletDetailViewCell: BaseTableViewCell {
    
    typealias Model = TokenWalletDetaillViewCellModel

    override func initCell() {
        super.initCell()
        
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        
        detailLabel.textColor = AppTheme.Color.text_light
        detailLabel.font = AppTheme.Font.text_small
        detailLabel.lineBreakMode = .byTruncatingMiddle
        
        addSubViews([
            nameLabel,
            detailLabel,
            rightArrow,
        ])
    }
    
    override func frameLayout() {
        let name_w = (nameLabel.text ?? "").boundingRect(with: CGSize.bounding, font: nameLabel.font).width
        rightArrow.updateFrame(CGRect(x: width - 33, y: height * 0.5 - 6.5, width: 8, height: 13))
        nameLabel.updateFrame(CGRect(x: 25, y: 0, width: name_w, height: height))
        let detail_w = rightArrow.isHidden ? (rightArrow.maxX - nameLabel.maxX - 10) : (rightArrow.x - nameLabel.maxX - 20)
        detailLabel.updateFrame(CGRect(x: nameLabel.maxX + 10, y: 0, width: detail_w, height: height))
    }
    
    override func configure(with row: TableViewRow) {
        guard let model: Model = row.serializeModel() else { return }
        nameLabel.text = model.title
        detailLabel.text = model.detail
        rightArrow.isHidden = !model.showArrow
        frameLayout()
    }

}
