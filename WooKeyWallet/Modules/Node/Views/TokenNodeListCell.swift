//
//  TokenNodeListCell.swift


import UIKit

class TokenNodeListCell: BaseTableViewCell {
    
    // MARK: - Properties (Private)
    
    private lazy var optionImageView: UIImageView = {
        return UIImageView()
    }()
    
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        nameLabel.textColor = AppTheme.Color.text_light
        nameLabel.font = AppTheme.Font.text_normal
        detailLabel.textColor = UIColor(hex: 0x26B479)
        detailLabel.font = AppTheme.Font.text_smaller
        detailLabel.textAlignment = .left
        contentView.addSubViews([
            nameLabel,
            detailLabel,
            optionImageView,
        ])
    }
    
    override func frameLayout() {
        let mid_Y = height * 0.5
        let nameH = nameLabel.font.lineHeight
        optionImageView.updateFrame(CGRect(x: nameLabel.maxX + 25, y: mid_Y - 10, width: 20, height: 20))
        nameLabel.updateFrame(CGRect(x: 26, y: optionImageView.y - 5, width: width - 95, height: nameH))
        detailLabel.updateFrame(CGRect(x: 26, y: nameLabel.maxY, width: nameLabel.width, height: detailLabel.font.lineHeight))
        
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: NodeOption = row.serializeModel() else { return }
        nameLabel.text = model.node
        if let fps = model.fps {
            detailLabel.text = "\(fps) ms"
        } else {
            detailLabel.text = ""
        }
        optionImageView.image = UIImage(named: model.isSelected ? "node_option_selected" : "node_option_normal")
    }
}
