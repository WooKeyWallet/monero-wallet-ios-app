//
//  AddressBookViewCell.swift


import UIKit

class AddressBookViewCell: DeleteConfirmationViewCell {
    
    // MARK: - Properties (private lazy)
        
    private lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "edit_icon"), for: .normal)
        return btn
    }()
    
    
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
        editBtn,
        ])
        
        editBtn.addTarget(self, action: #selector(toEditAction), for: .touchUpInside)
    }
    
    override func frameLayout() {
        let cell_mid_y = height * 0.5
        let textTotalH = nameLabel.font.lineHeight + 5 + detailLabel.font.lineHeight
        iconView.updateFrame(CGRect(x: 25, y: cell_mid_y - 14, width: 28, height: 28))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 10, y: (height - textTotalH) * 0.5, width: width - iconView.maxX - 70, height: nameLabel.font.lineHeight))
        detailLabel.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY + 5, width: nameLabel.width, height: detailLabel.font.lineHeight))
        editBtn.updateFrame(CGRect(x: width - 50, y: cell_mid_y - 15, width: 30, height: 30))
    }
    
        
    
    // MARK: - Configure
    
    override func configure(with row: TableViewRow) {
        super.configure(with: row)
        guard let model: AddressBook = row.serializeModel() else { return }
        iconView.image = model.tokenIcon
        nameLabel.text = model.label
        detailLabel.text = model.tokenAddress
    }
    
    
    // MARK: - Methods (action)
    
    @objc private func toEditAction() {
        self.actionHandler?(TableViewRowAction.edit)
    }

}
