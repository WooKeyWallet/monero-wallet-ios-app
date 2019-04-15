//
//  SendViewHeader.swift


import UIKit

class SendViewHeader: UIView {
    
    // MARK: - Properties (Lazy)
    
    public lazy var tokenIcon: UIImageView = {
        let iconV = UIImageView()
        iconV.layer.cornerRadius = 15
        iconV.layer.masksToBounds = true
        iconV.contentMode = .scaleAspectFill
        return iconV
    }()
    
    private lazy var tokenWalletNameLab: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    
    
    private lazy var remainTitleLab: UILabel = {
        let label = UILabel()
        label.text = LocalizedString(key: "send.amount.remain", comment: "")
        label.textColor = AppTheme.Color.text_light
        label.font = AppTheme.Font.text_small
        return label
    }()
    
    private lazy var remainLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.Color.text_dark
        label.font = AppTheme.Font.text_normal
        return label
    }()
    
    private lazy var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = AppTheme.Color.cell_line
        return line
    }()
    
    
    // MARK: - Life Cycles
    
    required init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.configureConstraints()
    }
    
    // MARK: - Configure
    
    internal func configureView() {
        backgroundColor = AppTheme.Color.page_common
        addSubViews([
        tokenIcon,
        tokenWalletNameLab,
        remainTitleLab,
        remainLabel,
        bottomLine,
        ])
    }
    
    internal func configureConstraints() {
        tokenIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        tokenWalletNameLab.snp.makeConstraints { (make) in
            make.left.equalTo(tokenIcon.snp.right).offset(10)
            make.centerY.equalTo(tokenIcon)
        }
        remainTitleLab.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.centerY.equalTo(tokenWalletNameLab)
        }
        remainLabel.snp.makeConstraints { (make) in
            make.top.equalTo(remainTitleLab.snp.bottom).offset(13)
            make.right.equalTo(remainTitleLab)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(px(1))
            make.top.equalTo(remainLabel.snp.bottom).offset(25)
        }
    }
    
    public func configureModels(model: (icon: UIImage?, walletName: String, amount: String)) {
        tokenIcon.image = model.icon
        tokenWalletNameLab.text = model.walletName
        remainLabel.text = model.amount
    }

}
