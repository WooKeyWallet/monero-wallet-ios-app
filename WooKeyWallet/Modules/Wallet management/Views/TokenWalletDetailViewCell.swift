//
//  TokenWalletDetailViewCell.swift


import UIKit

class TokenWalletDetailViewCell: BaseTableViewCell {

    override func initCell() {
        super.initCell()
        
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        
        detailLabel.textColor = AppTheme.Color.text_light
        detailLabel.font = AppTheme.Font.text_small
        
        addSubViews([
            nameLabel,
            detailLabel,
            rightArrow,
        ])
    }
    
    override func frameLayout() {
        let detail_w = (detailLabel.text ?? "").boundingRect(with: CGSize.bounding, font: detailLabel.font).width
        detailLabel.updateFrame(CGRect(x: width - 25 - detail_w, y: 0, width: detail_w, height: height))
        rightArrow.updateFrame(CGRect(x: width - 33, y: height * 0.5 - 6.5, width: 8, height: 13))
        let name_w = min(detailLabel.x, rightArrow.x) - 25
        nameLabel.updateFrame(CGRect(x: 25, y: 0, width: name_w, height: height))
    }
    
    override func configure(with row: TableViewRow) {
        guard let model: (title: String, detail: String) = row.serializeModel() else { return }
        nameLabel.text = model.title
        detailLabel.text = model.detail
        if model.detail == "" {
            detailLabel.isHidden = true
            rightArrow.isHidden = false
        } else {
            detailLabel.isHidden = false
            rightArrow.isHidden = true
        }
    }

}
