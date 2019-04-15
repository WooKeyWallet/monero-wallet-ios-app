//
//  LanguageViewCell.swift


import UIKit

class LanguageViewCell: BaseTableViewCell {

    // MARK: - Properties (Private)
    
    private lazy var optionImageView: UIImageView = {
        return UIImageView()
    }()
    
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        contentView.addSubViews([
            nameLabel,
            optionImageView,
        ])
    }
    
    override func frameLayout() {
        let mid_Y = height * 0.5
        nameLabel.updateFrame(CGRect(x: 25, y: mid_Y - 15, width: width - 95, height: 30))
        optionImageView.updateFrame(CGRect(x: nameLabel.maxX + 25, y: mid_Y - 10, width: 20, height: 20))
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: (name: String, isSelected: Bool) = row.serializeModel() else { return }
        nameLabel.text = model.name
        optionImageView.image = UIImage(named: model.isSelected ? "node_option_selected" : "node_option_normal")
    }
}
