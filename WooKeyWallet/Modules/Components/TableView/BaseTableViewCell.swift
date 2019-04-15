//
//  BaseTableViewCell.swift


import UIKit

class BaseTableViewCell: UITableViewCell, TableViewCellProtocol {
    
    // MARK: - Properties (Override)
    
    override var frame: CGRect {
        get { return super.frame }
        set {
            super.frame = newValue
            self.frameLayout()
        }
    }
    
    
    // MARK: - Properties (Lazy)
    
    internal lazy var iconView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.isUserInteractionEnabled = true
        return imgV
    }()
    
    internal lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal.medium()
        return label
    }()
    
    internal lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        label.textAlignment = .right
        return label
    }()
    
    internal lazy var rightArrow: UIImageView = {
        let imgV = UIImageView.init(image: UIImage(named: "cell_arrow_right"))
        return imgV
    }()
    
    
    // MARK: - Life Cycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initCell()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initCell()
    }
    
    func initCell() {
        selectionStyle = .none
        self.backgroundColor = AppTheme.Color.cell_bg
        contentView.backgroundColor = AppTheme.Color.cell_bg
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - TableViewRowable
    
    func configure(with row: TableViewRow) {
        
    }
    
    // MARK: - Layout

    func frameLayout() {
        
    }
}
