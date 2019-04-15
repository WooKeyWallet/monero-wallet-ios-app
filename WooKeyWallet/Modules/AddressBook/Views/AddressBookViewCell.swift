//
//  AddressBookViewCell.swift


import UIKit

class AddressBookViewCell: BaseTableViewCell {
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        
        iconView.layer.cornerRadius = 14
        iconView.layer.masksToBounds = true
        iconView.contentMode = .scaleAspectFill
        
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        
        detailLabel.textColor = AppTheme.Color.text_light
        detailLabel.font = AppTheme.Font.text_smaller
        detailLabel.textAlignment = .left
        
        contentView.addSubViews([
        iconView,
        nameLabel,
        detailLabel,
        ])
        
    }
    
    override func frameLayout() {
        let textTotalH = nameLabel.font.lineHeight + 5 + detailLabel.font.lineHeight
        iconView.updateFrame(CGRect(x: 25, y: (height - 28) * 0.5, width: 28, height: 28))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 10, y: (height - textTotalH) * 0.5, width: width - iconView.maxX - 35, height: nameLabel.font.lineHeight))
        detailLabel.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY + 5, width: nameLabel.width, height: detailLabel.font.lineHeight))
    }
    
    
    // MARK: - Configure
    
    override func configure(with row: TableViewRow) {
        guard let model: AddressBook = row.serializeModel() else { return }
        iconView.image = model.tokenIcon
        nameLabel.text = model.label
        detailLabel.text = model.tokenAddress
    }

}
