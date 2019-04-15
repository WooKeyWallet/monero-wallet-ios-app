//
//  TransactionListCell.swift


import UIKit

class TransactionListCell: BaseTableViewCell {
    
    // MARK: - Properties (Lazy)
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_smaller
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.main_green
        label.font = AppTheme.Font.text_smaller
        label.textAlignment = .right
        return label
    }()
    
    
    // MARK: - Life Cycles

    override func initCell() {
        super.initCell()
        
        nameLabel.font = AppTheme.Font.text_normal_
        detailLabel.font = AppTheme.Font.text_normal_.medium()
        detailLabel.textColor = AppTheme.Color.text_dark
        
        contentView.addSubViews([
        iconView,
        nameLabel,
        detailLabel,
        dateLabel,
        statusLabel,
        ])
    }
    
    override func frameLayout() {
        let line1H = max(detailLabel.font.lineHeight, nameLabel.font.lineHeight)
        let line2H = dateLabel.font.lineHeight
        let V_padding = CGFloat(8.0)
        let top = (height - line1H - V_padding - line2H) * 0.5
        iconView.updateFrame(CGRect(x: 25, y: top + (line1H - 15) * 0.5, width: 15, height: 15))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 10, y: top, width: 80, height: line1H))
        detailLabel.updateFrame(CGRect(x: nameLabel.maxX + 10, y: top, width: width - (nameLabel.maxX + 10) - 25, height: line1H))
        statusLabel.updateFrame(CGRect(x: width - 100, y: detailLabel.maxY + V_padding, width: 75, height: line2H))
        dateLabel.updateFrame(CGRect(x: nameLabel.x, y: nameLabel.maxY + V_padding, width: statusLabel.x - nameLabel.x - 10, height: line2H))
    }
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: TransactionListCellFrame = row.serializeModel() else { return }
        iconView.image = model.icon
        nameLabel.text = model.nameText
        detailLabel.text = model.detailText
        dateLabel.text = model.dateText
        statusLabel.text = model.statusText
        statusLabel.textColor = model.statusTextColor
    }

}
