//
//  TokenWalletViewCell.swift


import UIKit

class TokenWalletViewCell: BaseTableViewCell {
    
    enum Action: Int {
        case active
        case detail
    }
    
    // MARK: - Properties (Private)
    
    private var actionHandler: ((Any) -> Void)?

    // MARK: - Properties (Lazy)
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.page_common
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var label: UILabel = {
        let lab = UILabel()
        lab.textColor = AppTheme.Color.text_darker
        lab.font = AppTheme.Font.text_normal
        return lab
    }()
    
    private lazy var currentWalletBtn: BaseButton = {
        let btn = BaseButton()
        btn.imageTitlePostion = BaseButton.ImageTitlePostion.leftRight(padding: 4)
        btn.setTitle("\(LocalizedString(key: "wallet.management.inuse", comment: ""))", for: .normal)
        btn.setTitleColor(AppTheme.Color.button_title, for: .normal)
        btn.setImage(UIImage(named: "tokenWallet_switch_selected"), for: .normal)
        btn.setBackgroundImage(UIImage.colorImage(AppTheme.Color.status_green), for: .normal)
        btn.titleLabel?.font = AppTheme.Font.text_smaller
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        let text_w = btn.titleLabel!.text!.boundingRect(with: CGSize.bounding, font: AppTheme.Font.text_smaller).width
        btn.size = CGSize(width: text_w + 30, height: 24)
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private lazy var switchBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tokenWallet_switch_normal"), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0)
        return btn
    }()
    
    private lazy var topLine: UIView = {
        let line = UIView()
        line.backgroundColor = AppTheme.Color.cell_line
        return line
    }()
    
    private lazy var infoBG: UIView = {
        let bg = UIView()
        bg.backgroundColor = AppTheme.Color.page_common
        return bg
    }()
    
    // MARK: - Life Cycles
    
    override func initCell() {
        super.initCell()
        backgroundColor = AppTheme.Color.tableView_bg
        contentView.backgroundColor = AppTheme.Color.tableView_bg
        
        contentView.addSubview(containerView)
        
        containerView.addSubViews([
            label,
            currentWalletBtn,
            switchBtn,
            topLine,
            infoBG,
        ])
        
        infoBG.addSubViews([
            iconView,
            nameLabel,
            detailLabel,
            rightArrow,
        ])
        
        nameLabel.textColor = AppTheme.Color.text_dark
        nameLabel.font = AppTheme.Font.text_normal
        detailLabel.textColor = AppTheme.Color.text_dark
        detailLabel.font = AppTheme.Font.text_normal.medium()
        detailLabel.textAlignment = .right
        
        switchBtn.addTarget(self, action: #selector(self.switchBtnAction), for: .touchUpInside)
        infoBG.addTapGestureRecognizer(target: self, selector: #selector(self.toDetailAction))
    }

    override func frameLayout() {
        containerView.updateFrame(CGRect(x: 16, y: 5, width: width - 32, height: height - 10))
        containerView.layer.setDefaultShadowStyle()
        
        currentWalletBtn.updateFrame(CGRect(x: containerView.width - currentWalletBtn.width - 15, y: 22 - currentWalletBtn.height/2, width: currentWalletBtn.width, height: currentWalletBtn.height))
        switchBtn.updateFrame(CGRect(x: containerView.width - 45, y: 7, width: 30, height: 30))
        label.updateFrame(CGRect(x: 15, y: 0, width: switchBtn.x - 15, height: 44))
        
        topLine.updateFrame(CGRect(x: 15, y: label.maxY, width: containerView.width - 30, height: px(1)))
        
        infoBG.updateFrame(CGRect(x: topLine.x, y: topLine.maxY, width: topLine.width, height: containerView.height - topLine.maxY))
        
        iconView.updateFrame(CGRect(x: 0, y: infoBG.height * 0.5 - 15, width: 30, height: 30))
        nameLabel.updateFrame(CGRect(x: iconView.maxX + 11, y: iconView.y, width: 60, height: iconView.height))
        detailLabel.updateFrame(CGRect(x: nameLabel.maxX, y: nameLabel.y, width: infoBG.width - 18 - nameLabel.maxX, height: nameLabel.height))
        rightArrow.updateFrame(CGRect(x: detailLabel.maxX + 10, y: detailLabel.midY - 6.5, width: 8, height: 13))
    }
    
    
    // MARK: - Methods (Action)
    
    @objc private func switchBtnAction() {
        actionHandler?(Action.active)
    }
    
    @objc private func toDetailAction() {
        actionHandler?(Action.detail)
    }
    
    
    // MARK: - Configure Model
    
    override func configure(with row: TableViewRow) {
        guard let model: TokenWallet = row.serializeModel() else { return }
        label.text = model.label
        currentWalletBtn.isHidden = !model.in_use
        switchBtn.isHidden = model.in_use
        iconView.image = model.icon
        nameLabel.text = model.token
        detailLabel.text = model.amount
        
        self.actionHandler = row.actionHandler
    }
}
